// Signed-in phone-width screenshot through headless Chrome (DevTools protocol), for when the
// claude-in-chrome extension is not connected. Usage:
//   node shot.mjs <url> <out.png> <file holding the session token>
// Sets localStorage.fivepicks_token on the URL's origin, loads the page at 375px, captures the
// full page (capped at 4000px tall). Node 22+ (global WebSocket/fetch).
import { spawn } from "node:child_process";
import { readFileSync, writeFileSync, mkdtempSync } from "node:fs";
const [,, url, out, tokenFile] = process.argv;
const token = readFileSync(tokenFile, "utf8").trim();
const CH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const dir = mkdtempSync(process.env.TMPDIR + "/chr");
const p = spawn(CH, ["--headless=new", "--remote-debugging-port=9333", `--user-data-dir=${dir}`, "about:blank"], { stdio: "ignore" });
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40; i++) { try { const t = await (await fetch("http://127.0.0.1:9333/json")).json(); const pg = t.find(x => x.type === "page"); if (pg) { ws = new WebSocket(pg.webSocketDebuggerUrl); break; } } catch {} await sleep(250); }
await new Promise(r => ws.onopen = r);
let id = 0; const pending = {};
ws.onmessage = (m) => { const d = JSON.parse(m.data); if (d.id && pending[d.id]) { pending[d.id](d.result); delete pending[d.id]; } };
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending[i] = r; ws.send(JSON.stringify({ id: i, method, params })); });
await send("Emulation.setDeviceMetricsOverride", { width: 375, height: 812, deviceScaleFactor: 2, mobile: true });
const origin = new URL(url).origin;
await send("Page.navigate", { url: origin + "/robots.txt" }); await sleep(2000);
await send("Runtime.evaluate", { expression: `localStorage.setItem("fivepicks_token", ${JSON.stringify(token)})` });
await send("Page.navigate", { url }); await sleep(9000);
const { result } = await send("Runtime.evaluate", { expression: "document.documentElement.scrollHeight", returnByValue: true });
const h = Math.min(result.value || 812, 4000);
await send("Emulation.setDeviceMetricsOverride", { width: 375, height: h, deviceScaleFactor: 2, mobile: true }); await sleep(1500);
const shot = await send("Page.captureScreenshot", { format: "png" });
writeFileSync(out, Buffer.from(shot.data, "base64"));
ws.close(); p.kill();
