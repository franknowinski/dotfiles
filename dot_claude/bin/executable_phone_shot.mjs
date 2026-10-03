#!/usr/bin/env node
// Phone-width screenshot of any page through headless Chrome with real mobile emulation (the
// viewport meta tag applies, unlike `chrome --headless --window-size`, which renders a desktop
// window and clips the right edge). Prints anything sticking out past the right edge, skipping
// what sits inside a sideways scroller (overflow-x auto/scroll), which is meant to.
//
//   node ~/.claude/bin/phone_shot.mjs <url> <out.png> [--width 390] [--full] [--local KEY=FILE]...
//
//   --width N         viewport width in CSS px (default 390, an iPhone); captured at 2x
//   --full            capture the whole page height (capped at 4000px), not just one screen
//   --local KEY=FILE  before loading, set localStorage[KEY] on the URL's origin to FILE's
//                     contents (a sign-in token, e.g. fivepicks_token); repeatable
//
// Exits 1 if the page scrolls sideways, 2 on timeout. Node 22+ (global WebSocket/fetch).
import { spawn } from "node:child_process";
import { readFileSync, writeFileSync, mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const args = process.argv.slice(2);
const pos = [], locals = [];
let width = 390, full = false;
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--width") width = Number(args[++i]);
  else if (args[i] === "--full") full = true;
  else if (args[i] === "--local") { const [k, f] = args[++i].split("="); locals.push([k, readFileSync(f, "utf8").trim()]); }
  else pos.push(args[i]);
}
const [url, out] = pos;
if (!url || !out) { console.error("usage: phone_shot.mjs <url> <out.png> [--width N] [--full] [--local KEY=FILE]"); process.exit(64); }

const port = 9300 + Math.floor(Math.random() * 600);
const CH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const chrome = spawn(CH, ["--headless=new", `--remote-debugging-port=${port}`,
  `--user-data-dir=${mkdtempSync(join(tmpdir(), "chr"))}`, "about:blank"], { stdio: "ignore" });
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
setTimeout(() => { console.error("phone_shot: timed out"); chrome.kill(); process.exit(2); }, 60000).unref();

let ws;
for (let i = 0; i < 40 && !ws; i++) {
  try {
    const pages = await (await fetch(`http://127.0.0.1:${port}/json`)).json();
    const pg = pages.find(x => x.type === "page");
    if (pg) ws = new WebSocket(pg.webSocketDebuggerUrl);
  } catch {}
  if (!ws) await sleep(250);
}
if (ws.readyState !== WebSocket.OPEN) await new Promise(r => ws.onopen = r);
let id = 0; const pending = {};
ws.onmessage = (m) => { const d = JSON.parse(m.data); if (pending[d.id]) { pending[d.id](d.result); delete pending[d.id]; } };
const send = (method, params = {}) => new Promise(r => { pending[++id] = r; ws.send(JSON.stringify({ id, method, params })); });
const metrics = (height) => send("Emulation.setDeviceMetricsOverride", { width, height, deviceScaleFactor: 2, mobile: true });

await metrics(844);
if (locals.length) {
  await send("Page.navigate", { url: new URL(url).origin + "/robots.txt" }); await sleep(1500);
  for (const [k, v] of locals) await send("Runtime.evaluate", { expression: `localStorage.setItem(${JSON.stringify(k)}, ${JSON.stringify(v)})` });
}
await send("Page.navigate", { url });
await sleep(6000);

const { result } = await send("Runtime.evaluate", { returnByValue: true, expression: `(() => {
  const vw = document.documentElement.clientWidth;
  const inScroller = (e) => { for (let p = e.parentElement; p; p = p.parentElement) {
    const o = getComputedStyle(p).overflowX; if (o === "auto" || o === "scroll") return true; } return false; };
  const out = [...document.querySelectorAll("body *")]
    .filter(e => { const r = e.getBoundingClientRect(); return r.width > 0 && r.right > vw + 1 && !inScroller(e); })
    .map(e => e.tagName.toLowerCase() + (e.id ? "#" + e.id : "") + (typeof e.className === "string" && e.className ? "." + e.className.trim().split(/\\s+/).join(".") : ""));
  return { vw, scrollWidth: document.documentElement.scrollWidth, height: document.documentElement.scrollHeight, sticksOut: out.slice(0, 20) };
})()` });
const { height, ...report } = result.value;
console.log(JSON.stringify(report, null, 1));
if (full) { await metrics(Math.min(height || 844, 4000)); await sleep(1500); }
const shot = await send("Page.captureScreenshot", { format: "png" });
writeFileSync(out, Buffer.from(shot.data, "base64"));
ws.close(); chrome.kill();
process.exit(report.scrollWidth > report.vw ? 1 : 0);
