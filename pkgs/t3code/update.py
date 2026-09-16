import argparse
import base64
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

GITHUB_API = "https://api.github.com/repos/pingdotgg/t3code/releases"
NPM_REGISTRY = "https://registry.npmjs.org"
SERVER_ARCHITECTURES = {
    "x86_64-linux": "x64",
    "aarch64-linux": "arm64",
}
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


def release_asset_url(assets, version, filename):
    matches = [asset for asset in assets if asset.get("name") == filename]
    if len(matches) != 1:
        raise UpdateError(
            f"GitHub release v{version}: expected exactly one required asset "
            f"{filename}, found {len(matches)}"
        )
    asset = matches[0]
    size = asset.get("size")
    if asset.get("state") != "uploaded" or type(size) is not int or size <= 0:
        raise UpdateError(f"GitHub release v{version}: {filename} is not fully uploaded")
    url = f"https://github.com/pingdotgg/t3code/releases/download/v{version}/{filename}"
    if asset.get("browser_download_url") != url:
        raise UpdateError(f"GitHub release v{version}: unexpected URL for {filename}")
    return url


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
    desktop_url = release_asset_url(assets, version, f"T3-Code-{version}-x86_64.AppImage")
    server_urls = {
        system: release_asset_url(assets, version, f"t3-{version}-linux-{architecture}.tar.gz")
        for system, architecture in SERVER_ARCHITECTURES.items()
    }
    return version, desktop_url, server_urls


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
    return hash_value


def render_release(version, desktop_hash, server_hashes):
    version = normalize_version(version)
    desktop_hash = validate_hash(desktop_hash, "desktop hash")
    if server_hashes.keys() != SERVER_ARCHITECTURES.keys():
        raise UpdateError("server hashes must contain exactly x86_64-linux and aarch64-linux")
    hashes = "".join(
        f'    {system} = "{validate_hash(server_hashes[system], f"{system} server hash")}";\n'
        for system in SERVER_ARCHITECTURES
    )
    return (
        "{\n"
        f'  version = "{version}";\n'
        f'  desktopHash = "{desktop_hash}";\n'
        "  serverHashes = {\n"
        f"{hashes}"
        "  };\n"
        "}\n"
    )


def publish_release(destination, content):
    with tempfile.TemporaryDirectory(prefix=".t3code-update-", dir=destination.parent) as staging:
        replacement = Path(staging) / "release.nix"
        replacement.write_text(content, encoding="utf-8")
        replacement.chmod(stat.S_IMODE(destination.stat().st_mode))
        os.replace(replacement, destination)


def update(package_dir, selector=None):
    version, desktop_url, server_urls = resolve_release(selector)
    progress(f"Preparing t3code {version}")
    progress("Fetching desktop release")
    desktop_hash = prefetch_file(desktop_url)
    server_hashes = {}
    for system, url in server_urls.items():
        progress(f"Fetching {system} CLI release")
        server_hashes[system] = prefetch_file(url)
    release = render_release(version, desktop_hash, server_hashes)
    publish_release(package_dir / "release.nix", release)
    progress(f"Updated release.nix to {version}; nothing deployed")


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
