---
name: mac-cleanup
description: Audit the Mac Studio for clutter — scheduled jobs, orphaned dev servers, dead Tailscale slots, leftover test databases, unused Ollama models, big caches and old logs — report what is worth removing, and remove only what the user approves. Use when the user says "clean up the Mac", "mac cleanup", "garbage cleanup", "audit my tasks/jobs", or "what am I running".
---

# Mac cleanup

An on-demand audit of the always-on Mac Studio. **Report first, change nothing until the user
picks items.** Every deletion is per-item approval; "all" counts.

## 1. Gather (read-only, run in parallel)

- **launchd**: every `~/Library/LaunchAgents/*.plist` — label, program, schedule
  (`StartCalendarInterval` / `StartInterval` / `KeepAlive`), and `launchctl list` pid + last exit.
  A non-zero exit or a program path that no longer exists is a finding. Also glance at
  `/Library/LaunchAgents` and `/Library/LaunchDaemons` for non-Apple items. `crontab -l`.
- **Claude routines**: `RemoteTrigger` `list`. Disabled or `run_once_fired` routines are dead.
  Routines cannot be deleted through the API — the user deletes them at claude.ai/code/routines.
- **GitHub**: active workflows with a `schedule:` across non-archived repos (`gh repo list`).
  `~/actions-runner/*` self-hosted runners.
- **Fly**: `fly apps list` — suspended apps may still bill for volumes.
- **Listening processes**: `lsof -nP -iTCP -sTCP:LISTEN`, then `ps -o etime=,command=` per pid.
  Dev servers (vite, puma, rails, next) running from `.claude/worktrees/` or for more than a day
  are likely orphans.
- **Tailscale**: `/Applications/Tailscale.app/Contents/MacOS/Tailscale serve status`. A slot whose
  local port has no listener is dead.
- **Postgres** (`/opt/homebrew/opt/postgresql@17/bin/psql -d postgres`): databases named
  `*_test*`, `*_test-N`, `*_preview_*` — parallel test runs and old previews leave dozens.
- **Ollama**: `ollama list`, then grep `~/Projects` (excluding node_modules/.venv/.git) for each
  model name. Check only one `ollama serve` runs and that it is the `sh.brew.ollama` service.
- **Disk**: sizes of `~/Library/Caches`, `$(brew --cache)`, `~/.npm/_cacache`,
  `~/Library/Developer/Xcode/DerivedData`, `~/Library/Developer/CoreSimulator`, OrbStack/Docker
  images, `~/Library/Logs/*`, `~/Projects/*/.claude/worktrees`, `~/Projects/*/tmp`, and
  `~/Downloads` items older than 90 days (list only).

## 2. Report

Three groups, each item one line with size/age and why:
**Worth removing** (numbered), **Worth a look**, **Keep**. Say plainly what the user must do
themselves (routine deletion, revoking keys, phone apps).

## 3. Apply (only approved numbers)

Prefer reversible steps: `launchctl bootout` + move the plist aside before deleting;
`brew cleanup`, `npm cache clean --force`, `xcrun simctl delete unavailable`; `dropdb` per DB;
`git worktree remove` for worktrees (never one with uncommitted work — report it instead);
`tailscale serve --https=<port> off`. Verify each step and show the evidence.

## Never touch

- Tailscale **443 (kritic), 8443 (fivepicks previews), 10000 (hedgehog), 8444 (halfsies)**, and
  never run `tailscale serve reset`.
- The fivepicks runner (`actions.runner.*`), `net.fivepicks.*-poll`, `com.kritic.*`,
  `net.hedgehog.*`, `net.tendies.*` jobs — they do real work. Report failures, don't remove.
- Ollama model `qwen3.8:27b` (tendies' news watcher) or any model a project references.
- `api_development` and any non-test database; anything under `/data` or production.
- `db/development.sqlite3` in fivepicks.
