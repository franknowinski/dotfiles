---
name: work-the-board
description: Turn the Linear board into running work — read the current repo's agent-ready Todo cards in Personal Projects (DEV), plan waves of up to three cards that touch no file in common, show the plan and wait for a go, then build each card in its own background worktree agent through to a PR, review each PR cold with review-pr (one fix round on blocking findings), and put each PR on a phone preview on the Mac (bin/preview, over Tailscale) with a phone-width screenshot on its card. Use when the user says "work the board", "run the board", "start the ready cards", or asks to pick up several DEV cards at once.
---

# Work the board

One command turns ready cards into PRs, in parallel, without two agents editing the same file.
It runs **once per request** — no timers, no `/loop`, no polling (decided: that burns tokens on an
empty board and starts work nobody is around to test). Running it again later picks up whatever
merges have unblocked. It **never merges**: the user tries the preview on their phone and says
"merge".

Roles: **you** (this session) are the dispatcher — you plan, launch, and handle everything that is
a shared resource (the two preview slots, the screenshot browser). **Card agents** build one card
each, in their own worktree, and stop at an open PR.

Previews run on the user's always-on Mac Studio: `bin/preview` starts a branch's own dev servers
and publishes them over Tailscale on `:8443` or `:10000` (`:443` is the user's live checkout). There
is no hosted preview app and no fallback to one. If a repo has no `bin/preview`, skip the preview
steps and say so.

## 1. Find the repo and its cards

- Repo label: match the working directory against the `Repo` group's labels in team
  **Personal Projects** (`list_issue_labels` — each description starts with the repo path). No
  match → stop and say so.
- Cards: `list_issues` with team `Personal Projects`, state `Todo`, label `agent-ready`, then keep
  only those that also carry this repo's label. Fetch each with `get_issue(includeRelations: true)`
  for the full description and its `blockedBy`.
- Housekeeping, before planning: for any card left **In Progress** by a previous run with no PR
  attached, say so in the plan (an agent died or was stopped) rather than silently ignoring it.
  Remove worktrees whose branch has merged (`git worktree list`, `gh pr list --state merged
  --head <branch>`): `bin/preview stop <branch>` first if `bin/preview list` shows it, then
  `git worktree remove`.

## 2. Hold back what cannot start

- **Blocked:** any `blockedBy` card whose state is not Done (Canceled counts as unblocked).
- **Not really ready:** an Open questions section with anything in it — the `spec` skill should
  never have marked it `agent-ready`; say so.
- **Needs the user at the keyboard:** a card whose acceptance criteria require an interactive
  step (a signed-in phone check, a manual console edit, a secret only the user holds). It can
  still run, but flag it in the plan so its PR is expected to stop short of that step.

## 3. Predict the files each card touches

For each remaining card, list the files it will most likely change, from its Context section
**plus a quick read of the code** (grep the components, services and specs it names; follow one
level of imports when the card names a view). Record a confidence (high / medium) — a card that
says "areas involved: TeamRow.vue" is high; "somewhere in the sort logic" is medium.

Count these as shared even when the card does not name them:

- `db/schema.rb` and any migration — two cards that both migrate conflict on the schema version.
- Lockfiles (`Gemfile.lock`, `package-lock.json`) — any card adding a dependency.
- A spec file that covers a shared file.

`CLAUDE.md` is **not** a conflict when two cards edit different sections; treat it as one when
they edit the same section.

## 4. Plan waves

- Order candidates by priority (Urgent → Low, None last), then oldest first.
- Greedily fill wave 1: add a card if it shares no predicted file with a card already in it.
  **Cap: three cards.** Everything left over goes to wave 2, 3… under the same rule — shown for
  information only. Only wave 1 launches; later waves wait for a re-run, because merges change
  the code they would branch from.
- A medium-confidence card whose prediction is a near miss with another (same directory, same
  view tree) goes in a later wave rather than gambling.

Show the plan and **wait for the user's go**, unless the request already carries one: "walk the
board, go", "work the board and start DEV-10", "start with the ATS fix" and the like are the go —
show the plan and launch wave 1 in the same turn. A named card goes in wave 1 first, and the
rest of the wave fills around it by the overlap rule. A bare "work the board" still waits. Format:

```
Wave 1 (launches on go)
  DEV-11  Show distance to the paid places…   Improvement  High
          files: frontend/src/components/RankStrip.vue, spec … (high)
  DEV-12  …
Later waves (not launched)
  DEV-14  shares TeamRow.vue with DEV-10 → wave 2
Held back
  DEV-7   blocked by DEV-6 (In Progress)
```

The user may drop, swap or add cards; re-check overlap after any change.

## 5. Launch wave 1

One `Agent` call per card, all in the **same message** so they start together, each with
`isolation: "worktree"`, `run_in_background: true` (they are background by default), a
description like `DEV-11 rank strip`, and the brief below with the blanks filled. Do not pass
`model` — the agents inherit this session's.

Before launching, confirm the main checkout has the gitignored files the test suites need (for
Rails, `config/master.key`) so you can give their absolute paths in the brief.

### Card agent brief

```
You are building Linear card <DEV-N> in <repo path>, in your own git worktree. Other agents are
building other cards in parallel in their own worktrees; do not touch any checkout but yours.

Card (full text):
<paste the card's description>

1. Move <DEV-N> to In Progress with the Linear MCP (save_issue state "In Progress", assignee "me").
2. Branch from the latest main — not from whatever your worktree started on:
     git fetch origin && git switch -c <kebab-case-branch> origin/main
3. Set up the worktree. Copy these gitignored files from the main checkout: <absolute paths,
   e.g. /Users/.../config/master.key>. Then follow the repo's setup (CLAUDE.md / README): for a
   Rails + frontend repo, `bundle install`, `bin/rails db:test:prepare`, and `npm ci` in the
   frontend directory.
4. Read the repo's CLAUDE.md and every doc the card links, then build the card. Meet every
   acceptance criterion you can. Stay inside the card's scope: anything else you notice goes in
   your final report, not in the diff.
   Files predicted for this card: <list>. Other agents are editing: <the other cards' predicted
   files>. If the work turns out to need one of theirs, stop and report instead of editing it.
   The card's "Fix direction" (or Design) is a suggestion, not a spec. You may take a different
   route when it is clearly better, but say so up front: the PR body's second paragraph starts
   `Deviates from the card:` with what you did instead and why, and the same goes on the report's
   DEVIATIONS line. Never bury it in NOTES.
5. Run the full checks the repo's CI runs (both suites). Red → fix it or stop and report; never
   open a PR on a red tree.
6. Ship: read <repo>/.claude/skills/ship/SKILL.md and follow it — commit, push, open the PR with
   `Linear: [<DEV-N>](<card url>)` as its first line, move the card to In Review and attach the
   PR link. Do not merge. Do not deploy or start a preview — the dispatcher does that, because
   there are only two preview slots.
7. Finish with a report in exactly this shape, and nothing after it:
     CARD: <DEV-N>
     PR: <url>            (or NONE, and why)
     BRANCH: <branch>
     TESTS: <commands and pass/fail counts>
     SCREENSHOT: <path on the site to open, and what to look at>   or   NONE — no visible change
     SIGNED_IN: yes/no    (does that page need a signed-in session to show the change)
     PREVIEW: yes/no      (should the DISPATCHER put this PR on a phone preview for the user to try?
                           yes for any change under app/, config/, db/ or frontend/src/ — anything
                           a user could see or the server runs. no ONLY for lint/CI config, docs,
                           spec-only or dev tooling. Not about whether you started one — you never do.)
     CRITERIA NOT MET: <each unmet acceptance criterion and why, or "none">
     DEVIATIONS: <where the build departs from the card's fix direction or design, and why, or "none">
     DATA: <what production needs after deploy for the change to show — a migration, a
           sync or backfill task — or "none">
     NOTES: <follow-ups, surprises, anything outside scope you noticed>
```

Tell the user in one line per card that it launched, then stop and wait. Do not poll: each agent's
completion arrives as a notification.

## 6. As each agent finishes

Handle completions **one at a time, in the order they arrive** — the preview slots and the
screenshot browser are shared.

1. Read its report. If `PR: NONE` or a check failed, leave the card where the agent left it, add a
   card comment with the reason, and report it; skip the rest.
   Otherwise **launch the review first**, then carry on with the preview while it runs: one
   background `Agent` (no worktree; it only reads) with the brief `Review PR #<N> in <repo path>:
   read <repo>/.claude/skills/review-pr/SKILL.md and follow it. Finish with VERDICT: Ready | Needs
   changes, then each finding as path:line — problem — breaking scenario.` The review waits on CI
   and never edits code, so running it beside the preview costs no wall time. A preview is not a
   merge — it runs on a copy of the dev database on the user's own Mac — so it does not wait for
   the verdict; the **notification** does (step 7).
2. **Preview** — only if the repo has `bin/preview` **and** the report's `PREVIEW:` line is `yes`.
   Skip it (and the screenshot and the preview link on the card) for a change with no runtime
   effect: lint/CI config, docs, spec-only, dev tooling. When skipped, say so in the card comment
   and the report (`preview — skipped, no runtime change`); the review still runs and the
   notification still fires. Check the agent's answer against the diff (`gh pr diff <N>
   --name-only`): a `no` on a PR touching `app/`, `config/`, `db/` or `frontend/src/` is wrong —
   preview it anyway. From the main checkout, by absolute path:

   ```bash
   <main checkout>/bin/preview <DEV-N>      # Bash timeout 600000: a cold worktree installs and compiles
   ```

   The URL is the last line. It refuses a branch that predates preview support ("merge main into
   it"): merge `origin/main` into the card's branch in its worktree, push, and re-run — that is the
   builder's own branch, so it is fine here. Any other failure (Tailscale down, a server that will
   not boot — the output ends with its log) → comment it on the card, leave the card In Review
   without a preview link, and say so in the notification. There is no fallback host.
   Post the link on the PR: `gh pr comment <N> --body "Preview: <url> (<sha>)"`. If the output
   says it evicted another preview, comment on **that** card too: `Preview for PR #M was stopped to
   make room for PR #N; run bin/preview DEV-X (or say "preview DEV-X") to bring it back.`
3. **Screenshot** — when the report names a page. Every fivepicks page needs a sign-in (signed
   out, `/` shows only the Google button — do not trust an agent's `SIGNED_IN: no`), and the
   user's Chrome holds no session for a preview's origin, so mint one **in the preview's own
   database**:

   ```bash
   cd <worktree> && DATABASE_URL=sqlite3:<worktree>/tmp/preview/development.sqlite3 \
     bin/rails runner 'puts Session.issue!(User.find_by!(email: "<user email>")).last' | tail -1 > <scratch>/preview_token
   node ~/.claude/skills/work-the-board/shot.mjs <preview url+path> <out.png> <scratch>/preview_token
   ```

   `shot.mjs` drives headless Chrome at 375px with that token in `localStorage`. Crop a tall
   capture to the part that matters (`sips -c <h> 750 --cropOffset 0 0`) and **look at it before
   attaching** — a sign-in page is not a screenshot of the change. **Never mint a session, or run
   anything that writes, against production (`sportslook`).** No browser available at all → say so
   on the card and in the report; do not fake a screenshot.
4. **PR description** — put the screenshot in the PR body as well, because that is where the user
   reviews. GitHub has no API for uploading images to a PR, and a Linear upload URL expires
   within minutes, so push the image to the orphan `pr-screenshots` branch (never merged)
   under `pr-<N>/`. Use git plumbing so no checkout is touched: `hash-object -w` →
   `mktree`, building on the branch's current tree → `commit-tree -p origin/pr-screenshots` →
   `git push origin "${sha}:refs/heads/pr-screenshots"`. Write the braces: zsh reads `$sha:r`
   as a modifier. Then edit the body with a Python replace and `gh pr edit --body-file`; zsh
   `${var/pat/repl}` silently fails to match `##`. Replace any screenshot placeholder
   line, or add a `## Screenshot` section before `## Testing`:
   `<img src="https://github.com/<owner>/<repo>/blob/pr-screenshots/pr-<N>/<file>?raw=true" width="320">`
   plus one line saying what to look at. The repo is private, so this renders only for
   signed-in viewers with access, which is everyone who reviews it.
5. **Card** — attach to the card (Linear MCP):
   - the preview URL as a link titled `Preview (PR #N)`;
   - the screenshot: `prepare_attachment_upload` → `curl -X PUT --data-binary @file` with the
     signed headers verbatim → `create_attachment_from_upload`, one file at a time, within 60s;
   - a comment: `Preview of PR #N (<sha>): <url>`.
6. Re-read the card and confirm it is In Review with the PR link attached; fix it if not. Do not
   trust the agent's own move: Linear's GitHub integration applies its "PR opened" automation a
   few seconds *after* the PR is created and can overwrite the agent's In Review (DEV-10 bounced
   back to In Progress this way). The team's Git automation should map "PR opened" → In Review so
   the two agree; this check is the backstop if it ever drifts.
7. **Wait for the review verdict, then notify** — never ping the user to test code the reviewer
   is about to flag.
   - **Ready** (optional notes allowed) → `PushNotification`: `DEV-N ready to test: <preview url>
     — <one-line what to check>`.
   - **Needs changes** → blocking means a correctness bug or an unmet acceptance criterion, which
     is what `review-pr` already reports as Needs changes; its "Optional" list never blocks.
     Send the findings back to the card's builder with `SendMessage` (its worktree and context
     are intact): fix these, re-run both suites, push to the same branch, **reply on the PR**,
     and report in the same shape. The reply is one `gh pr comment`, so the PR page shows the
     finding was answered and not left hanging:
     ```markdown
     ## Fixes (builder): reply to <link to the review comment>

     1. Fixed in <sha>: <what changed>
     2. Not changed: <why>
     ```
     One line per finding, numbered the same as the review. An "Optional" item gets a line only
     if it was acted on. The preview runs the branch's own dev servers, so it picks up the fix by
     itself — run `bin/preview list` to confirm it is still healthy, re-screenshot if the page
     changed, and re-run the review. Resume the same reviewer with `SendMessage` when it is still
     around; `review-pr` checks every reply line against the diff and marks its old verdict
     superseded. Only then notify. **One fix round only**: if the second review still says Needs
     changes, stop — comment the findings on the card, leave it In Review, and notify
     `DEV-N needs you: review still failing after one fix — <top finding>`.
   The notification is skipped when the user is at the terminal, which is fine; it is for when
   they have walked away. The reviewer is the same model as the builder, so a Ready is a second
   look, not a substitute for the user's test.

## 7. Report

When the wave is done (or when the user asks mid-way), one line per card:

```
DEV-11  In Review  PR #66  review ✓  preview :8443 ✓  screenshot ✓
DEV-12  In Review  PR #67  review ✓ (1 optional)  preview ✗ (no visible change)
DEV-13  In Review  PR #68  review ✗ after 1 fix round — see card comment
DEV-9   Stopped    tests red in home_sort.spec.js — see card comment
Re-run "work the board" after merging to start wave 2.
```

Under each card, a **Verify** line the user can act on from a phone: the full preview URL of the
page to open, and what to look for (from the card's "See it working" and the agent's SCREENSHOT
line). Give one even for a card with no visible change — say what should look *the same* and how
to compare it (e.g. open the same page on production side by side). Only when nothing is
checkable in the app (a log line, a Sentry event, a spec-only change) say where it can be seen
instead — a Sentry search, `/api/v1/health`, the PR's Testing section. Two previews run at a
time; a third card's preview evicts the oldest, so say which cards currently hold `:8443` and
`:10000` (`bin/preview list`).

Then add each agent's NOTES and unmet criteria, briefly. The worktrees (and their previews) stay
until their PR merges; the next run stops and removes them.
