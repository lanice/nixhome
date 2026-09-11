# Screencast reference

## Change coverage

Use the requested comparison base, or infer it from the branch's PR target and repository
conventions. Record the base and compared revision in the storyboard. Inspect the diff and
relevant implementation, using commits and specs as context rather than a substitute for the
actual changes. Account for uncommitted work separately when it belongs to the requested scope.

Map every change to demonstrated behavior, no browser-visible effect, or a concrete blocker.
Group related changes into viewer-facing scenes rather than recording one clip per file or commit.
Show backend changes through their UI effects when observable. Keep nonvisual changes in the
coverage report. An inaccessible requested behavior remains a limitation, not a completed scene.

## Preparation

- **Target and server:** use the existing site or the project's documented dev command.
  For a local server, use an available scratch port and the environment's supervised process
  facility. Observe readiness and retain the process handle for teardown.
- **Authentication:** each section gets a new browser context. Pass approved Playwright
  `contextOptions`, such as `storageState`, to `screencast` for pre-authenticated sessions.
  The runner does not inherit the user's logged-in browser. Keep credentials outside the
  project and footage; if access requires the user, request that step.
- **Replay:** use test accounts and resettable data. Restore server-side state between probes,
  recording, and retries; a fresh context only resets browser state. Keep required setup in each
  section or its repeatable preparation. Obtain authorization before real purchases, messages,
  or destructive actions on a live site.
- **Continuity:** navigation in the same page stays in one video. The runner retains only its
  original page's video; popups and additional tabs are not assembled into it. If the requested
  flow requires those, browser chrome, native dialogs, or audio, use a capture method that
  supports them or resolve the limitation with the user before scripting.

## Running a script

Always inside `shell.nix` beside the harness. It provides nixpkgs' `playwright-test`, the
matching `playwright-driver.browsers` (Chromium plus the minimal ffmpeg Playwright records with,
versions pinned together) and `ffmpeg-headless` for the contact sheets and MP4, and exports their
paths. Nothing is taken from the project, so any project works, and so does no project at all.

```
nix-shell <skill dir>/shell.nix --run 'node screencast.mjs'                   # record every section
PROBE=1 nix-shell <skill dir>/shell.nix --run 'node screencast.mjs'           # dry run, screenshots on failure
SECTION="Search" nix-shell <skill dir>/shell.nix --run 'node screencast.mjs'  # one section
VIEWPORT=420x860 nix-shell <skill dir>/shell.nix --run 'node screencast.mjs'  # a phone-width pass, same sections
CAPTIONS=0 nix-shell <skill dir>/shell.nix --run 'node screencast.mjs'        # no caption bar
```

`outDir` receives `NN-name.webm` per section, `results.json` (per section: `ok`, `claims` in
order, `captions` on or off, console errors), and `*-failed.png` from probes.
The first run fetches the browser set; later runs hit the store. `nix-shell` on its own drops
into the environment for debugging by hand.

Run commands from the scratch directory, or pass the script's absolute path. Import
`screencast` from the absolute path to this skill's `harness.mjs`; the section callback receives
the helpers as `h`, with the full Playwright Page at `h.page`. The runner accepts `baseURL`,
`outDir`, `sections`, optional `viewport`, and optional Playwright `contextOptions`.

`h.caption(text, ms)` draws text when enabled and holds the frame; it always appends text to
`claims`. `h.pause(ms)` holds without changing the caption. Probes skip both holds.
After navigation, call `h.caption` again if the new page needs text.

Each invocation replaces `results.json`, including a `SECTION` retry. Preserve each run's report
outside that path before running again. Use the latest successful, visually verified take of
each section and its report for delivery; a retry report alone does not cover the whole storyboard.

## Verify: contact sheets

```js
import { contactSheet, toMp4, duration } from '<this skill directory>/harness.mjs';
contactSheet('out/03-search.webm', 'out/03-search', { everySeconds: 5, cols: 4, rows: 4 });
contactSheet(video, prefix, { start: 200, duration: 60, everySeconds: 3 });  // a time range
toMp4(['out/01-a.webm', 'out/02-b.webm'], 'out/walkthrough.mp4');
```

One sheet holds `cols × rows` frames; long sections produce `prefix-01.png`, `prefix-02.png`, …
Read them as images against the storyboard. Pick `everySeconds` below the shortest outcome hold
for both captioned and uncaptioned footage. If text is unreadable on the sheet, use a larger
`width` or smaller grid. Use denser frames or playback for transitions the sampling misses.

## Gotchas that are not project-specific

- **Dev copy differs from test copy.** Wait strings lifted from unit tests often miss in the
  browser. Probe with the real page text.
- **Virtualized lists** only mount rows in view. Reach a row by a URL filter or by scrolling the
  container, never by a locator on an off-screen row.
- **Canvas UIs** may lack DOM targets. Identify the intended canvas by its container and bounds,
  then use coordinates relative to it. Verify the result visually or through an accessible
  side effect such as a tooltip.
- **Locator collisions:** toolbar and per-row buttons can share names. Scope by region, row,
  or an exact accessible name. The input helpers use `.first()`, which hides ambiguity.
- **Clipboard and downloads:** clipboard-read/write permissions are enabled by default.
  `h.clipboard()` returns a fallback string on failure; `h.download(locator, saveDir)` waits
  for the download but returns `null` on timeout. Check the result when the scene depends on it.
- **Console errors:** the runner collects console errors and uncaught page errors. Report the
  observed message and page; a console error alone does not establish its cause.
