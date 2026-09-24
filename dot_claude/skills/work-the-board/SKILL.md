---
name: work-the-board
description: Turn the Linear board into running work — read the current repo's agent-ready Todo cards in Personal Projects (DEV), plan waves of up to three cards that touch no file in common, show the plan and wait for a go, then build each card in its own background worktree agent through to a PR, and put each PR on staging with a phone-width screenshot on its card. Use when the user says "work the board", "run the board", "start the ready cards", or asks to pick up several DEV cards at once.
---

# Work the board

One command turns ready cards into PRs, in parallel, without two agents editing the same file.
It runs **once per request** — no timers, no `/loop`, no polling (decided: that burns tokens on an
empty board and starts work nobody is around to test). Running it again later picks up whatever
merges have unblocked. It **never merges**: the user tests on staging and says "merge".

Roles: **you** (this session) are the dispatcher — you plan, launch, and handle everything that is
a single shared resource (staging, the user's Chrome). **Card agents** build one card each, in
their own worktree, and stop at an open PR.

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
  --head <branch>`), with `git worktree remove`.

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

Show the plan and **wait for the user's go**. Nothing launches without it. Format:

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
5. Run the full checks the repo's CI runs (both suites). Red → fix it or stop and report; never
   open a PR on a red tree.
6. Ship: read <repo>/.claude/skills/ship/SKILL.md and follow it — commit, push, open the PR with
   `Linear: [<DEV-N>](<card url>)` as its first line, move the card to In Review and attach the
   PR link. Do not merge. Do not deploy anywhere, staging included — the dispatcher does that,
   because staging holds one PR at a time.
7. Finish with a report in exactly this shape, and nothing after it:
     CARD: <DEV-N>
     PR: <url>            (or NONE, and why)
     BRANCH: <branch>
     TESTS: <commands and pass/fail counts>
     SCREENSHOT: <path on the site to open, and what to look at>   or   NONE — no visible change
     SIGNED_IN: yes/no    (does that page need a signed-in session to show the change)
     CRITERIA NOT MET: <each unmet acceptance criterion and why, or "none">
     NOTES: <follow-ups, surprises, anything outside scope you noticed>
```

Tell the user in one line per card that it launched, then stop and wait. Do not poll: each agent's
completion arrives as a notification.

## 6. As each agent finishes

Handle completions **one at a time, in the order they arrive** — staging and the browser are
single resources.

1. Read its report. If `PR: NONE` or a check failed, leave the card where the agent left it, add a
   card comment with the reason, and report it; skip the rest.
2. **Staging** — only if the repo's CLAUDE.md has a Staging section; follow it. For fivepicks:

   ```bash
   gh workflow run deploy-staging.yml -f ref=<branch>
   sleep 5
   gh run watch "$(gh run list --workflow deploy-staging.yml --limit 1 --json databaseId --jq '.[0].databaseId')" --exit-status
   ```

   Use the manual dispatch, **not** the `staging` PR label: a label keeps redeploying that PR on
   every later push, so two labelled PRs would take staging back and forth. The workflow ends by
   checking `/api/v1/health` reports the staging app. If it fails, report the failing step and
   leave the card In Review without a staging link.
3. **Screenshot** — when the report names a page. Load the `claude-in-chrome` skill and use the
   user's own Chrome, which holds their staging session (`localStorage.fivepicks_token`): open the
   staging URL + path, set the viewport to **375px wide**, and capture the part of the page the
   report names. Save it as a PNG in the scratchpad.
   - Signed-in page but no signed-in browser: fallback is minting a session **on staging only** —
     `fly ssh console --app fivepicks-staging -C "bin/rails runner 'puts Session.issue!(User.find_by!(email: \"<user email>\")).last'"` — then set `localStorage.fivepicks_token` to it and reload. **Never run this, or anything that writes, against production (`sportslook`).**
   - No browser available at all → say so on the card and in the report; do not fake a screenshot.
4. **Card** — attach to the card (Linear MCP):
   - the staging URL as a link titled `Staging (PR #N)`;
   - the screenshot: `prepare_attachment_upload` → `curl -X PUT --data-binary @file` with the
     signed headers verbatim → `create_attachment_from_upload`, one file at a time, within 60s;
   - a comment: `Staging now shows PR #N (<sha>).` When this moves staging off another card's
     PR, also comment on **that** card: `Staging moved to PR #M (DEV-X); redeploy this PR with
     gh workflow run deploy-staging.yml -f ref=<branch> to test it again.`
5. Confirm the card is In Review with the PR link attached (the agent's `ship` step should have
   done it; fix it if not).

## 7. Report

When the wave is done (or when the user asks mid-way), one line per card:

```
DEV-11  In Review  PR #66  staging ✓  screenshot ✓
DEV-12  In Review  PR #67  staging ✗ (no visible change)
DEV-9   Stopped    tests red in home_sort.spec.js — see card comment
Staging now shows PR #66 (DEV-11).  Re-run "work the board" after merging to start wave 2.
```

Add each agent's NOTES and unmet criteria underneath, briefly. The worktrees stay until their PR
merges; the next run removes them.
