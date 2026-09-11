---
name: screencast
description: Screencasts of browser features, branch changes, and user flows, with optional captions. Use when asked for a browser screen recording or walkthrough video.
---

# Screencast

Turn the request into a **storyboard**, then rehearse, record, and inspect the footage.
`harness.mjs` beside this file records headless Chromium pages with a cursor, paced input,
and optional captions. It captures page content, not browser chrome or native dialogs.
Recordings have no audio. Captions are on by default; "silent" alone does not turn them off.

## 1. Scope

Use the request to decide what the viewer should see:

- **Feature:** find its entry point and demonstrate the requested behavior.
- **Branch changes:** establish the comparison base and inventory the changes. Follow
  [change coverage](reference.md#change-coverage) before choosing scenes.
- **User flow:** establish the starting state, follow the requested path, and show the destination.
- **Other browser recordings:** derive scenes from the requested pages, actions, and outcomes.

Write the storyboard in a scratch directory outside the project. Each scene names its purpose,
starting state, actions, and visible outcome. Add viewer-facing caption text when captioned;
link spec items only when supplied. Group scenes into **sections**, each independently replayable
in a fresh browser context. Keep a stateful journey in one section even when it crosses screens.

Done when every requested behavior maps to a scene or an explicit coverage limitation, and
scene order preserves the requested flow. Resolve ambiguities from the conversation and project;
ask only when a scope or access decision remains.

## 2. Prepare

Consult browser-check documentation if the project's agent instructions point to it. Discover
missing routes, locators, and setup on the actual site; keep recording-specific notes with the
storyboard. Use the target URL, starting a local server only when the target requires one.
For authentication, repeatable data, and capture limits, read
[preparation](reference.md#preparation).

Done when the target is reachable and every section has a reproducible starting state and
locator strategy. Probing and recording both execute real actions.

## 3. Script

Read [running a script](reference.md#running-a-script) for the runtime and runner options.
Write `screencast.mjs` beside the storyboard, importing `screencast` from this skill's
`harness.mjs`. Pass `baseURL`, `outDir`, and `sections`, each with `name` and `run(h)`.
Use `h.caption`, `h.click`, `h.hover`, `h.typeSlow`, `h.pause`, `h.clipboard`, `h.download`,
and `h.page` for Playwright actions and state-based waits.

Write captions for the viewer. Keep verification outcomes in the storyboard whether captioned
or not; the harness's `claims` field records `h.caption` text, not proof of an outcome.
Use `h.pause` for viewing time without text. Scope locators to the intended element; the input
helpers choose the first match, so uniqueness must be deliberate. Wait for observable state,
then hold it long enough to read; pauses supply pacing, not readiness.

Done when every scene is scripted and each section can run from its own starting state.

## 4. Probe

Run inside this skill's `shell.nix` with `PROBE=1`: no video, no pacing, a screenshot on failure.
Fix the failing setup, locator, or action and rerun with `SECTION=<name>`, then rerun the whole
probe from the prepared starting states. Done when every section reports `ok` in one run.

## 5. Record

Restore the starting states and run without `PROBE`. Use `CAPTIONS=0` when captions are unwanted.
Each section lands as `NN-name.webm` in `outDir`. Fix failed sections and rerun them with
`SECTION=<name>`; preserve run reports as described in the reference.
Done when every storyboard section has a successful recording and a corresponding run report.

## 6. Verify

Build and inspect [contact sheets](reference.md#verify-contact-sheets) against the storyboard's
visible outcomes, with or without captions. Inspect denser frames or play the relevant segment
when a sheet cannot establish a transition or pacing. Done when every outcome is visible in
order, text is readable, and captions neither obscure the demonstrated UI nor claim unseen
behavior. Re-record sections that fail visual inspection even if their scripts ran green.

## 7. Deliver

Use `toMp4` to join the verified section videos in storyboard order. Check the assembled video's
opening, joins, and ending. Send the file when supported, otherwise give its path. Report coverage
and any limitations, including changes with no browser-visible behavior. Report observed console
errors with their pages, distinguishing them from diagnosed causes. Stop servers started for the
recording and remove temporary credentials; keep the delivered video accessible.
