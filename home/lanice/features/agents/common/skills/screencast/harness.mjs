// Screencast harness: headless Playwright with video, a visible cursor, a caption bar, slow
// human-paced input, and one run per section. Import it from a walkthrough script:
//
//   import { screencast } from '<this skill directory>/harness.mjs';
//   await screencast({ baseURL, outDir, sections: [{ name, run: async (h) => { ... } }] });
//
// Run scripts inside `shell.nix` beside this file; it supplies Playwright and its browsers from
// nixpkgs. Env: PROBE=1 runs without video and screenshots on failure. SECTION=<name> runs one
// section. VIEWPORT=WxH overrides the size. CAPTIONS=0 records without the caption bar; the
// caption texts still land in results.json as each section's list of claims.

import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ---------------------------------------------------------------- setup

// `shell.nix` sets PLAYWRIGHT_TEST_DIR to nixpkgs' playwright-test, PLAYWRIGHT_BROWSERS_PATH to
// the matching browser set (Chromium plus the ffmpeg Playwright records with), and FFMPEG.
function env(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is not set; run scripts inside shell.nix beside this harness`);
  return value;
}

async function loadChromium() {
  const req = createRequire(path.join(env('PLAYWRIGHT_TEST_DIR'), 'lib', 'node_modules', '@playwright', 'test', 'package.json'));
  return req('@playwright/test').chromium;
}

// Playwright's own ffmpeg is a minimal build for recording; the tools below need the full one
// shell.nix exports as FFMPEG.
function ffmpegBinary() {
  return env('FFMPEG');
}

// ---------------------------------------------------------------- overlays

// A red ring that follows the pointer and a caption bar at the bottom. Injected before any page
// script runs, so every navigation keeps them.
function overlayScript() {
  document.addEventListener('DOMContentLoaded', () => {
    const dot = document.createElement('div');
    Object.assign(dot.style, {
      position: 'fixed', width: '18px', height: '18px', borderRadius: '50%', zIndex: 2147483647,
      background: 'transparent', border: '2px solid rgb(180,0,0)', pointerEvents: 'none',
      transform: 'translate(-50%,-50%)', left: '-100px', top: '-100px', transition: 'transform 80ms',
    });
    document.body.appendChild(dot);
    document.addEventListener('mousemove', (e) => { dot.style.left = `${e.clientX}px`; dot.style.top = `${e.clientY}px`; }, true);
    document.addEventListener('mousedown', () => { dot.style.transform = 'translate(-50%,-50%) scale(0.6)'; }, true);
    document.addEventListener('mouseup', () => { dot.style.transform = 'translate(-50%,-50%)'; }, true);
    const cap = document.createElement('div');
    cap.id = '__screencast_caption';
    Object.assign(cap.style, {
      position: 'fixed', left: '50%', bottom: '18px', transform: 'translateX(-50%)', zIndex: 2147483646,
      background: 'rgba(20,20,20,0.88)', color: '#fff', padding: '10px 16px', borderRadius: '8px',
      font: '15px system-ui, sans-serif', maxWidth: '85vw', pointerEvents: 'none', display: 'none',
      boxShadow: '0 2px 12px rgba(0,0,0,0.4)',
    });
    document.body.appendChild(cap);
  });
}

// ---------------------------------------------------------------- per-page helpers

function helpers(page, { probe, captions, claims }) {
  const h = {
    page,
    sleep,
    // State a claim about what is on screen and hold it. With captions on it is drawn in the bar;
    // off, only the hold remains, so pacing is identical either way. Every claim is recorded for
    // verification. In probe mode the hold is skipped: probes check steps, not pacing.
    async caption(text, ms = 1800) {
      claims.push(text);
      if (captions) {
        await page.evaluate((t) => {
          const c = document.getElementById('__screencast_caption');
          if (c) { c.textContent = t; c.style.display = 'block'; }
        }, text);
      }
      if (!probe) await sleep(ms);
    },
    // Move the pointer to a locator in visible steps.
    async hover(locator) {
      const target = locator.first();
      await target.scrollIntoViewIfNeeded();
      const box = await target.boundingBox();
      if (!box) throw new Error(`no bounding box for ${locator}`);
      await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: probe ? 1 : 12 });
      await sleep(probe ? 0 : 350);
    },
    async click(locator) {
      await h.hover(locator);
      await locator.first().click();
      await sleep(probe ? 0 : 600);
    },
    async typeSlow(locator, text) {
      await h.click(locator);
      await locator.first().fill('');
      if (text) await locator.first().pressSequentially(text, { delay: probe ? 0 : 110 });
      await sleep(probe ? 0 : 900);
    },
    async pause(ms) {
      if (!probe) await sleep(ms);
    },
    clipboard: () => page.evaluate(() => navigator.clipboard.readText().catch(() => '(clipboard unavailable)')),
    // Click something that triggers a download and return { filename, path, bytes }, or null.
    async download(locator, saveDir) {
      const [dl] = await Promise.all([
        page.waitForEvent('download', { timeout: 5000 }).catch(() => null),
        h.click(locator),
      ]);
      if (!dl) return null;
      const target = path.join(saveDir, dl.suggestedFilename());
      await dl.saveAs(target);
      return { filename: dl.suggestedFilename(), path: target, bytes: fs.statSync(target).size };
    },
  };
  return h;
}

// ---------------------------------------------------------------- runner

export async function screencast({ baseURL, outDir, sections, viewport: viewportIn, contextOptions = {} }) {
  const probe = process.env.PROBE === '1';
  const captions = process.env.CAPTIONS !== '0';
  const only = process.env.SECTION;
  const viewport = process.env.VIEWPORT
    ? (([w, hgt]) => ({ width: Number(w), height: Number(hgt) }))(process.env.VIEWPORT.split('x'))
    : (viewportIn ?? { width: 1440, height: 900 });
  fs.mkdirSync(outDir, { recursive: true });

  const chromium = await loadChromium();
  const browser = await chromium.launch({ headless: true });

  const results = [];
  const chosen = only ? sections.filter((s) => s.name === only) : sections;
  if (chosen.length === 0) throw new Error(`no section named ${only}`);

  for (const section of chosen) {
    const slug = `${String(sections.indexOf(section) + 1).padStart(2, '0')}-${section.name.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}`;
    const ctx = await browser.newContext({
      baseURL,
      viewport,
      deviceScaleFactor: 1,
      permissions: ['clipboard-read', 'clipboard-write'],
      ...(probe ? {} : { recordVideo: { dir: path.join(outDir, 'raw'), size: viewport } }),
      ...contextOptions,
    });
    await ctx.addInitScript(overlayScript);
    const page = await ctx.newPage();
    const consoleErrors = [];
    page.on('console', (m) => { if (m.type() === 'error') consoleErrors.push(m.text()); });
    page.on('pageerror', (e) => consoleErrors.push(`pageerror: ${e.message}`));

    const started = Date.now();
    const claims = [];
    let error = null;
    try {
      await section.run(helpers(page, { probe, captions, claims }));
    } catch (e) {
      error = e;
      if (probe) await page.screenshot({ path: path.join(outDir, `${slug}-failed.png`), fullPage: false }).catch(() => {});
    }
    await page.close();
    let video = null;
    if (!probe) {
      const raw = await page.video().path();
      video = path.join(outDir, `${slug}.webm`);
      await ctx.close();
      fs.renameSync(raw, video);
    } else {
      await ctx.close();
    }
    const seconds = ((Date.now() - started) / 1000).toFixed(1);
    results.push({ name: section.name, slug, ok: !error, error: error?.message ?? null, video, captions, claims, consoleErrors, seconds });
    console.log(`${error ? 'FAIL' : 'ok  '} ${slug} (${seconds}s)${error ? `: ${error.message.split('\n')[0]}` : ''}`);
    if (error && probe) break;
  }
  await browser.close();
  fs.rmSync(path.join(outDir, 'raw'), { recursive: true, force: true });

  const failed = results.filter((r) => !r.ok);
  const noisy = results.filter((r) => r.consoleErrors.length);
  if (noisy.length) {
    console.log('\nconsole errors (findings, not noise, unless the project doc says otherwise):');
    for (const r of noisy) for (const e of [...new Set(r.consoleErrors)]) console.log(`  [${r.slug}] ${e.split('\n')[0].slice(0, 200)}`);
  }
  fs.writeFileSync(path.join(outDir, 'results.json'), JSON.stringify(results, null, 2));
  if (failed.length) {
    console.log(`\n${failed.length} section(s) failed; see ${outDir}/*-failed.png`);
    process.exitCode = 1;
  }
  return results;
}

// ---------------------------------------------------------------- video tools

function ffmpeg(args) {
  execFileSync(ffmpegBinary(), ['-hide_banner', '-loglevel', 'error', '-y', ...args], { stdio: 'inherit' });
}

// Tiled frames to read as an image: `out-01.png`, `out-02.png`, … one per `cols*rows` frames.
export function contactSheet(video, outPrefix, { everySeconds = 5, cols = 4, rows = 4, width = 480, start, duration } = {}) {
  ffmpeg([
    ...(start !== undefined ? ['-ss', String(start)] : []),
    '-i', video,
    ...(duration !== undefined ? ['-t', String(duration)] : []),
    '-vf', `fps=1/${everySeconds},scale=${width}:-1,tile=${cols}x${rows}`,
    `${outPrefix}-%02d.png`,
  ]);
}

// Concat the section videos in order and encode one MP4. Sections share a viewport, so no scaling.
export function toMp4(videos, out) {
  const list = `${out}.txt`;
  fs.writeFileSync(list, videos.map((v) => `file '${path.resolve(v)}'`).join('\n'));
  ffmpeg([
    '-f', 'concat', '-safe', '0', '-i', list,
    '-c:v', 'libx264', '-preset', 'fast', '-crf', '23', '-pix_fmt', 'yuv420p',
    '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2',
    '-movflags', '+faststart',
    out,
  ]);
  fs.unlinkSync(list);
}

export function duration(video) {
  const bin = ffmpegBinary();
  // `-i` with no output exits non-zero by design; the duration is in its stderr either way.
  let text = '';
  try {
    execFileSync(bin, ['-hide_banner', '-i', video], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    text = String(e.stderr ?? '');
  }
  return /Duration: ([\d:.]+)/.exec(text)?.[1] ?? null;
}
