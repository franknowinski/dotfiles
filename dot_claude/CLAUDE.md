# Preferences

- Keep explanations concise: lead with the answer, skip filler and restating the question, use short bullets over long paragraphs, and only go into detail when asked.
- Verify your own work without being asked: when there's an obvious check (tests, running the command, a phone-width screenshot of a UI change), run it and show the evidence. When the right check isn't obvious, propose one in a line before building, so the user isn't the one finding the bugs.
- UI changes: the user looks at everything on an iPhone, so screenshot the changed page with `node ~/.claude/bin/phone_shot.mjs <url> <out.png> [--full] [--local KEY=FILE]` (iPhone-width emulation; `--local` puts a sign-in token in localStorage), look at the image, and fix anything clipped, overlapping or cramped before calling it done. It exits 1 and names the culprits if the page scrolls sideways. Never judge layout from `chrome --headless --window-size`: it renders a desktop window and clips the right edge. Native iOS apps (Expo, e.g. kritic): open the screen in the iOS Simulator and take `xcrun simctl io booted screenshot <out.png>` instead.

# Home Mac Studio

- The user's Mac Studio (64GB/1TB) is **always on and awake**. It's the default host for running dev apps and previews; don't suggest paid hosting (e.g. Fly staging) for previews.
- On Tailscale as `franks-mac-studio.tail3f1556.ts.net` (tailnet-only HTTPS). Serve allows ports 443, 8443, 10000 only: **443 = kritic, 8443 = fivepicks (card previews, one at a time), 10000 = hedgehog (formerly arb-app).** One port per app — a local checkout of any of them is viewed on localhost at home; each app gets its own port; never serve an SPA from a sub-path.
- If the repo has `bin/preview`, use it (or the `preview` skill) to put a branch/card on the phone. Otherwise: run the app's dev server on a free port and `tailscale serve --bg --https=<slot> <port>`. Never run `tailscale serve reset` — it drops the other slots.
- Tailscale CLI is `/Applications/Tailscale.app/Contents/MacOS/Tailscale` (aliased `tailscale` in zsh; not on PATH for non-interactive shells).
- Rails dev apps need the tailnet host allowed: `config.hosts << /\A[a-z0-9-]+\.[a-z0-9-]+\.ts\.net(:\d+)?\z/` (the `".ts.net"` shorthand only admits one subdomain level). Google sign-in needs each `https://…ts.net[:port]` registered as an OAuth JavaScript origin.
- The user drives sessions from the phone via `claude remote-control` on this Mac.
