import argparse
import base64
import json
import os
import re
import stat
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

GITHUB_API = "https://api.github.com/repos/pingdotgg/t3code/releases"
NPM_REGISTRY = "https://registry.npmjs.org"
VERSION_PATTERN = re.compile(
    r"(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)"
    r"(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
)


class UpdateError(Exception):
    pass


def progress(message):
    print(message, file=sys.stderr, flush=True)


def object_value(value, context):
    if not isinstance(value, dict):
        raise UpdateError(f"{context}: expected a JSON object")
    return value


def parse_json(content, context):
    try:
        return object_value(json.loads(content), context)
    except (ValueError, UnicodeError) as error:
        raise UpdateError(f"{context}: invalid JSON: {error}") from error


def normalize_version(value):
    if not isinstance(value, str):
        raise UpdateError("release version must be a string")
    version = value.removeprefix("v")
    if not VERSION_PATTERN.fullmatch(version):
        raise UpdateError(f"invalid release version: {value!r}")
    return version


def fetch_json(url):
    request = Request(url, headers={
        "Accept": "application/json",
        "User-Agent": "t3code-nix-update",
    })
    try:
        with urlopen(request, timeout=60) as response:
            return parse_json(response.read(), url)
    except HTTPError as error:
        raise UpdateError(f"{url}: HTTP {error.code} {error.reason}") from error
    except URLError as error:
        raise UpdateError(f"{url}: {error.reason}") from error


def validate_release(release, expected_version=None, stable=False):
    release = object_value(release, "GitHub release")
    tag = release.get("tag_name")
    version = normalize_version(tag)
    if tag != f"v{version}":
        raise UpdateError(f"GitHub release has unexpected tag: {tag!r}")
    if expected_version is not None and version != expected_version:
        raise UpdateError(f"GitHub release is {version}, expected {expected_version}")
    if release.get("draft") is not False:
        raise UpdateError(f"GitHub release v{version} is a draft or lacks draft status")
    if not isinstance(release.get("prerelease"), bool):
        raise UpdateError(f"GitHub release v{version} lacks prerelease status")
    if stable and (release["prerelease"] or "-" in version.split("+", 1)[0]):
        raise UpdateError(f"latest stable GitHub release is a prerelease: v{version}")
    assets = release.get("assets")
    if not isinstance(assets, list) or any(not isinstance(asset, dict) for asset in assets):
        raise UpdateError(f"GitHub release v{version}: expected an assets array")
    filename = f"T3-Code-{version}-x86_64.AppImage"
    matches = [asset for asset in assets if asset.get("name") == filename]
    if len(matches) != 1:
        raise UpdateError(f"GitHub release v{version}: expected exactly one {filename}")
    asset = matches[0]
    size = asset.get("size")
    if asset.get("state") != "uploaded" or type(size) is not int or size <= 0:
        raise UpdateError(f"GitHub release v{version}: {filename} is not fully uploaded")
    url = f"https://github.com/pingdotgg/t3code/releases/download/v{version}/{filename}"
    if asset.get("browser_download_url") != url:
        raise UpdateError(f"GitHub release v{version}: unexpected URL for {filename}")
    return version, url


def resolve_release(selector=None, get_json=fetch_json):
    if selector is None:
        return validate_release(get_json(f"{GITHUB_API}/latest"), stable=True)
    if selector == "nightly":
        tags = object_value(
            get_json(f"{NPM_REGISTRY}/-/package/t3/dist-tags"), "npm dist-tags"
        )
        version = normalize_version(tags.get("nightly"))
        if tags["nightly"] != version:
            raise UpdateError("npm nightly dist-tag must contain an unprefixed version")
    else:
        version = normalize_version(selector)
    return validate_release(get_json(f"{GITHUB_API}/tags/v{version}"), version)


def validate_npm_metadata(metadata, version):
    metadata = object_value(metadata, "npm package metadata")
    if metadata.get("name") != "t3" or metadata.get("version") != version:
        raise UpdateError(f"npm metadata does not describe t3@{version}")
    distribution = object_value(metadata.get("dist"), f"npm t3@{version} dist")
    url = f"{NPM_REGISTRY}/t3/-/t3-{version}.tgz"
    if distribution.get("tarball") != url:
        raise UpdateError(f"npm t3@{version}: unexpected tarball URL")
    return url


def run_command(arguments, **kwargs):
    try:
        return subprocess.run(arguments, check=True, **kwargs)
    except subprocess.CalledProcessError as error:
        raise UpdateError(f"{arguments[0]} failed with exit status {error.returncode}") from error


def validate_hash(value, context):
    if not isinstance(value, str) or not value.startswith("sha256-"):
        raise UpdateError(f"{context}: expected a SHA-256 SRI hash")
    try:
        digest = base64.b64decode(value[7:], validate=True)
    except ValueError as error:
        raise UpdateError(f"{context}: invalid SHA-256 SRI hash") from error
    if len(digest) != 32:
        raise UpdateError(f"{context}: invalid SHA-256 digest length")
    return value


def prefetch_file(url):
    result = run_command(
        ["nix", "store", "prefetch-file", "--json", "--hash-type", "sha256", url],
        stdout=subprocess.PIPE,
    )
    data = parse_json(result.stdout, "nix store prefetch-file")
    hash_value = validate_hash(data.get("hash"), "nix store prefetch-file")
    store_path = data.get("storePath")
    if not isinstance(store_path, str) or not Path(store_path).is_absolute():
        raise UpdateError("nix store prefetch-file: missing absolute storePath")
    path = Path(store_path)
    if not path.is_file() or path.stat().st_size == 0:
        raise UpdateError(f"nix store prefetch-file: missing or empty artifact: {path}")
    return hash_value, path


def validate_manifest(manifest, version):
    manifest = object_value(manifest, "npm package.json")
    if manifest.get("name") != "t3" or manifest.get("version") != version:
        raise UpdateError(f"tarball package.json does not describe t3@{version}")
    dependencies = object_value(manifest.get("dependencies"), "package.json dependencies")
    if any(not isinstance(value, str) for value in dependencies.values()):
        raise UpdateError("package.json dependencies must contain version strings")
    return manifest


def read_package_manifest(tarball, version):
    try:
        with tarfile.open(tarball, mode="r:gz") as archive:
            matches = [member for member in archive if member.name == "package/package.json"]
            if len(matches) != 1 or not matches[0].isfile():
                raise UpdateError("npm tarball must contain one regular package/package.json")
            with archive.extractfile(matches[0]) as source:
                manifest = parse_json(source.read(), "tarball package/package.json")
    except tarfile.TarError as error:
        raise UpdateError(f"invalid npm tarball: {error}") from error
    return validate_manifest(manifest, version)


def npm_environment(work_dir):
    environment = {
        key: value for key, value in os.environ.items()
        if not key.lower().startswith("npm_config_") and key not in ("NODE_OPTIONS", "NODE_PATH")
    }
    home = work_dir / "home"
    home.mkdir()
    for filename in ("user.npmrc", "global.npmrc"):
        (work_dir / filename).write_text("")
    environment.update({
        "HOME": str(home),
        "npm_config_cache": str(work_dir / "npm-cache"),
        "npm_config_userconfig": str(work_dir / "user.npmrc"),
        "npm_config_globalconfig": str(work_dir / "global.npmrc"),
    })
    return environment


def prepare_lock(package_dir, work_dir, manifest, version):
    project = work_dir / "package"
    project.mkdir()
    result = run_command(
        ["jq", "--from-file", str(package_dir / "runtime-package.jq")],
        input=json.dumps(manifest).encode(), stdout=subprocess.PIPE,
    )
    filtered = validate_manifest(parse_json(result.stdout, "runtime package filter"), version)
    (project / "package.json").write_bytes(result.stdout)
    lock_path = project / "package-lock.json"
    lock_path.write_bytes((package_dir / "package-lock.json").read_bytes())
    environment = npm_environment(work_dir)
    run_command(
        ["npm", "install", "--package-lock-only", "--ignore-scripts", "--no-audit", "--no-fund"],
        cwd=project, env=environment, stdout=sys.stderr,
    )
    lock_bytes = lock_path.read_bytes()
    lock = parse_json(lock_bytes, "generated package-lock.json")
    packages = object_value(lock.get("packages"), "package-lock.json packages")
    root = object_value(packages.get(""), "package-lock.json root package")
    if lock.get("version") != version or root.get("version") != version:
        raise UpdateError(f"generated package-lock.json does not pin t3@{version}")
    if root.get("dependencies") != filtered["dependencies"]:
        raise UpdateError("generated package-lock.json has mismatched runtime dependencies")
    progress("Prefetching npm dependencies")
    result = run_command(
        ["prefetch-npm-deps", str(lock_path)],
        cwd=project, env=environment, stdout=subprocess.PIPE, text=True,
    )
    return lock_bytes, validate_hash(result.stdout.strip(), "prefetch-npm-deps")


def render_release(version, desktop_hash, server_hash, npm_deps_hash):
    version = normalize_version(version)
    fields = {
        "version": version,
        "desktopHash": validate_hash(desktop_hash, "desktop hash"),
        "serverHash": validate_hash(server_hash, "server hash"),
        "npmDepsHash": validate_hash(npm_deps_hash, "npm dependency hash"),
    }
    return "{\n" + "".join(f'  {key} = "{value}";\n' for key, value in fields.items()) + "}\n"


def publish_outputs(outputs, staging_dir):
    staged = []
    for index, (destination, content) in enumerate(outputs.items()):
        original = destination.read_bytes()
        mode = stat.S_IMODE(destination.stat().st_mode)
        backup = staging_dir / f"{index}.original"
        replacement = staging_dir / f"{index}.new"
        backup.write_bytes(original)
        replacement.write_bytes(content)
        backup.chmod(mode)
        replacement.chmod(mode)
        staged.append((destination, replacement, backup))
    replaced = []
    try:
        # Each rename is atomic, but the pair is not a global transaction.
        for destination, replacement, backup in staged:
            os.replace(replacement, destination)
            replaced.append((destination, backup))
    except BaseException as error:
        failures = []
        for destination, backup in reversed(replaced):
            try:
                os.replace(backup, destination)
            except OSError as restore_error:
                failures.append(f"{destination}: {restore_error}")
        if failures:
            raise UpdateError(
                f"publication failed: {error}; could not restore: {'; '.join(failures)}"
            ) from error
        raise


def update(package_dir, selector=None):
    version, desktop_url = resolve_release(selector)
    server_url = validate_npm_metadata(fetch_json(f"{NPM_REGISTRY}/t3/{version}"), version)
    progress(f"Preparing t3code {version}")
    progress("Fetching desktop release")
    desktop_hash, _ = prefetch_file(desktop_url)
    progress("Fetching npm server release")
    server_hash, tarball = prefetch_file(server_url)
    manifest = read_package_manifest(tarball, version)
    with tempfile.TemporaryDirectory(prefix="t3code-update-", dir="/tmp") as temporary:
        progress("Preparing package lock")
        lock_bytes, npm_deps_hash = prepare_lock(package_dir, Path(temporary), manifest, version)
        release = render_release(version, desktop_hash, server_hash, npm_deps_hash)
        # Stage outside the checkout, near it so renames use the same filesystem.
        repo = package_dir.parents[1]
        with tempfile.TemporaryDirectory(prefix=".t3code-publish-", dir=repo.parent) as staging:
            publish_outputs({
                package_dir / "release.nix": release.encode(),
                package_dir / "package-lock.json": lock_bytes,
            }, Path(staging))
    progress(f"Updated release.nix and package-lock.json to {version}; nothing deployed")


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Pin matching T3 Code desktop and server releases. Does not deploy or restart services.",
    )
    parser.add_argument(
        "selector", nargs="?", metavar="nightly|VERSION",
        help="latest npm nightly, or an exact version with optional v prefix; default: latest stable GitHub release",
    )
    arguments = parser.parse_args(argv)
    try:
        update(Path(__file__).resolve().parent, arguments.selector)
    except (UpdateError, OSError, UnicodeError) as error:
        progress(f"error: {error}")
        return 1
    except KeyboardInterrupt:
        progress("error: interrupted")
        return 130
    return 0


if __name__ == "__main__":
    sys.exit(main())
