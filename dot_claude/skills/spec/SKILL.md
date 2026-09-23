---
name: spec
description: Turn an idea, bug, or chore into a Linear card in the Personal Projects (DEV) team — classify it, grill the user until it is specified, then write the card in the matching template and mark it agent-ready when it qualifies. Use when the user says spec, write a card, make a ticket, "I have an idea", "grill me on", or describes work they want done later in any repo.
---

# Spec: from a loose idea to a Linear card

The card is the entire brief for whoever builds it — usually a fresh Claude session with none of
this conversation. It must be self-contained: goal, scope, and a check that proves it's done.

## 1. Classify

Choose the type from what the user said. Tell them which type you picked in a single line, and
only ask when two readings are genuinely plausible.

| Type | Linear label | It is this when… | Grill depth |
|---|---|---|---|
| **Feature** | `Feature` (new) / `Improvement` (changes an existing one) | a user would notice the difference | full rounds |
| **Bug** | `Bug` | something behaves differently from how it's meant to | one or two rounds |
| **Chore** | `Chore` | cleanup, refactor, deps, docs, tooling, where users notice nothing | one short round |
| **Idea** | `Idea` | not ready to build, or a whole new project | capture only, 0–2 questions |

A cleanup that changes what users see is a Feature/Improvement. If one request mixes types,
split it into separate cards.

**Repo:** set exactly one label from the `Repo` group. Infer it from the working directory or the
conversation, by matching the label names and descriptions (they hold
each repo's path and purpose). When still unsure, ask. A brand-new project idea gets no Repo
label.

## 2. Grill

Before asking anything, read the repo's `CLAUDE.md` and the code the idea touches, so each
question reflects how the system actually works. Without a checkout (a cloud or mobile session),
use whatever repository access you have. If you have none, write Context from what the user tells
you and add an Open question: "builder: confirm the areas involved against the code". That keeps
the card out of `agent-ready` until the builder has checked the code.

Interview in **rounds**:
- Each round asks every question whose prerequisites are already settled. Number the questions
  and give your recommended answer for each. A question that depends on another open question
  waits for a later round.
- **Look up facts yourself**, with the code, git history, and tools. Never ask the user for
  something you could find. Put only **decisions** to them.
- If a question needs something to react to (a layout, or how an interaction feels), stop
  grilling it. Put it in Open questions, or suggest a throwaway prototype.
- You're done when nothing is left silently assumed. Summarise the decisions and get the user's
  confirmation before writing.

```
❓ **Q1 – <title>**: <question, with options if useful>
➡️ <your recommendation>
```

Per-type focus:
- **Feature:** who it's for; what they see before and after; edge cases; what's explicitly out.
- **Bug:** exact reproduction steps; expected vs actual; evidence such as errors, Sentry, or
  data. Put a hypothesis about the cause in the card labelled as a hypothesis, never as fact.
- **Chore:** why now; what must not change; how you'd know it broke something.
- **Idea:** one sentence on what it is and why it matters. Stop there unless the user wants
  more.

## 3. Write the card

Title: imperative and specific ("Show kickoff time on pick cards", not "Kickoff time").

All four templates share one skeleton, so the builder always finds the same sections:
**Goal → type-specific sections → Out of scope → Context → Acceptance criteria → Verification →
Open questions.** For Context, link to a CLAUDE.md section or file rather than pasting it, and
leave out file-by-file descriptions the builder can read for themselves.

### Feature / Improvement

```markdown
## Goal
<What changes for the user, and why. 1–2 sentences.>

## Behaviour
- Before: …
- After: …
- Edge cases: …

## Design
<UI cards only. Screenshot/mockup link. Name specific styles to avoid.>

## Out of scope
- …

## Context
- Areas involved: …
- Rules and gotchas: <links to CLAUDE.md sections>

## Acceptance criteria
- [ ] <observable behaviour>

## Verification
- Must pass: <exact test commands>
- See it working: <page / endpoint / expected output>

## Open questions
- …
```

### Bug

```markdown
## Goal
<Restore the intended behaviour. One sentence.>

## Reproduce
1. …

## Expected / Actual
- Expected: …
- Actual: …

## Evidence
<error text, Sentry link, data, screenshots>

## Suspected cause (hypothesis)
<Unverified. The builder confirms or discards it.>

## Out of scope
- …

## Context
- …

## Acceptance criteria
- [ ] A test that fails before the fix and passes after
- [ ] <the expected behaviour above>

## Verification
- Must pass: <exact test commands>

## Open questions
- …
```

### Chore

```markdown
## Goal
<What gets cleaner, and why now.>

## Must not change
- <user-visible behaviour, public interfaces, data>

## Out of scope
- …

## Context
- …

## Acceptance criteria
- [ ] <the concrete cleanup, stated so it can be checked>
- [ ] No user-visible behaviour change

## Verification
- Must pass: <exact test commands, the full suites>

## Open questions
- …
```

### Idea

```markdown
## Pitch
<One or two sentences: what it is.>

## Why
<The problem or opportunity.>

## Open questions
- …
```

## 4. Create it

Before creating, show the full draft card, then create it in team **Personal Projects**
(`DEV`) with the Linear MCP:

- Labels: the type label, plus the Repo label when there is one.
- Add **`agent-ready`** and state **Todo** only if Acceptance criteria and Verification are both
  filled in and Open questions is empty. Otherwise use state **Backlog** and tell the user what
  is still open.
- **Idea** cards always go to Backlog and are never agent-ready.
- **Never** put an issue in a Linear Project. Repo is a label.

Reply with the issue identifier and link, plus any open questions that kept it out of
`agent-ready`.
