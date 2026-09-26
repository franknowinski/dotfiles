# Preferences

- Keep explanations concise: lead with the answer, skip filler and restating the question, use short bullets over long paragraphs, and only go into detail when asked.

# Home Mac Studio

- The user's Mac Studio (64GB/1TB) is **always on and awake**. It's the default host for running dev apps and previews; don't suggest paid hosting (e.g. Fly staging) for previews.
- On Tailscale as `franks-mac-studio.tail3f1556.ts.net` (tailnet-only HTTPS). Serve allows ports 443, 8443, 10000 only: **443 = the repo being live-edited, 8443 = fivepicks previews (one at a time), 10000 = arb-app dashboard.** Each app gets its own port; never serve an SPA from a sub-path.
- If the repo has `bin/preview`, use it (or the `preview` skill) to put a branch/card on the phone. Otherwise: run the app's dev server on a free port and `tailscale serve --bg --https=<slot> <port>`. Never run `tailscale serve reset` — it drops the other slots.
- Tailscale CLI is `/Applications/Tailscale.app/Contents/MacOS/Tailscale` (aliased `tailscale` in zsh; not on PATH for non-interactive shells).
- Rails dev apps need the tailnet host allowed: `config.hosts << /\A[a-z0-9-]+\.[a-z0-9-]+\.ts\.net(:\d+)?\z/` (the `".ts.net"` shorthand only admits one subdomain level). Google sign-in needs each `https://…ts.net[:port]` registered as an OAuth JavaScript origin.
- The user drives sessions from the phone via `claude remote-control` on this Mac.
