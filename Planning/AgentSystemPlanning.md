# Agent system planning

Planned growth of the agent setup — skills, hooks, agents, MCP, distribution — with the trigger that makes each item due. A working list, not a commitment. The project rules in [CLAUDE.md](../CLAUDE.md) win on scope; app features live in [FeaturePlanning.md](FeaturePlanning.md) and [AIFeaturePlanning.md](AIFeaturePlanning.md).

The project is run as if it were a multi-developer company: branches, tickets, reviews, and possibly, last, a backend with its own reviewer subagents. The setup grows when a trigger appears, not all at once.

## Item list

- **Distribution:** repo layer · personal plugin · enterprise managed settings · cross-tool portability (AGENTS.md)
- **Team mode:** personal memory → repo · shared vs local settings · Linear + GitHub MCP · branch-aware commit guard · PR review skill · CI verification
- **Subagents:** built — `ios-reviewer` (2026-10-28; replaced the parked verification skill) · parked — flow-reviewer (see §4). No iOS implementer: implementation's intermediate work matters, and the skills already load in the main thread.
- **Backend (last, optional):** backend skills scoped by `paths` · backend reviewer and research subagents
- **Parked automation:** routines · headless ingest · Knowledge ingest skill · SwiftUI expert extracts · extra hooks · instructions-loaded audit
- **Custom agents:** PR review bot · Knowledge ingest agent — goal 2 in README, not optional
- **Size budget:** limits that keep the agent system maintainable by one person

---

## 1. Distribution layers

Where each part of the setup lives decides who gets it and which version wins.

| Layer | Who gets it | Precedence | Holds |
|---|---|---|---|
| **Enterprise** (managed settings directory on each machine) | every machine in the organization | highest: overrides personal and project skills of the same name | rules that **must** hold everywhere: security, compliance, commit and secrets guards |
| **Personal** (`~/.claude/`, auto memory) | one developer, one machine | above project | preferences and learnings of one person |
| **Project** (`.claude/` in the repo) | anyone who clones the repo | base | rules tied to this codebase: architecture, design system, navigation |
| **Plugin** (marketplace) | anyone who installs it, any repo | namespaced (`plugin:skill`), never collides | generic, reusable parts of the system |

| Today in the repo | Target layer |
|---|---|
| architecture, navigation, dependency-injection, design-system skills · toolbar-on-Screen hook | project |
| skill-authoring, previews, code-style skills · stage-don't-commit hooks · previews-in-DEBUG hook · compact context restore | plugin (generic once FitTap names are isolated) |
| commit guard · future secrets redaction | enterprise, once there is a team to enforce it on |

Governance: `strictKnownMarketplaces` in managed settings limits which marketplaces a team may install plugins from.

## 2. Team mode

Due when the project starts working through branches, tickets, and more than one developer or agent at a time.

| Item | What changes | Why |
|---|---|---|
| **Personal memory → repo** | Rules that live only in one machine's auto memory (backlogs, feedback that applies to everyone) move into CLAUDE.md, skills, or `Planning/`. | Other developers and agents can't see personal memory. |
| **Shared vs local settings** | `.claude/settings.json` holds team hooks and permissions; personal permission tweaks move to `.claude/settings.local.json` (gitignored). | One developer's convenience must not loosen the team's guards. |
| **Linear + GitHub MCP** | MCP servers declared in a committed `.mcp.json`; tickets link to branches and PRs. | Every agent sees the same tickets and PRs. |
| **Branch-aware commit guard** | Commits are allowed on feature branches and still guarded on `main`; the Stop hook may expect commits instead of staged-only work there. | "Stage, don't commit" fits a solo checkout, not a branch workflow. |
| **PR review skill** | A review skill (or forked reviewer) that checks a PR against the project skills. | One consistent review standard across developers. |
| **CI verification** | Headless `claude -p` or a pre-commit step that checks the diff against the skills and fails on violations. | Rules hold even when nobody is watching the session. |
| **AGENTS.md** | Agent-neutral rules shared with non-Claude tools (Codex, Cursor), with CLAUDE.md importing them. | Developers may run different agents on the same repo. |

## 3. Backend (last, optional)

Built last, and only if a feature needs it: a backend adds running costs (hosting, and Claude API tokens per request per user).

**AI coach: PCC first, Claude backend only if needed.** Swift rules decide the numbers; on-device Foundation Models phrases nudges and short summaries; the iOS 27 Private Cloud Compute model (same API) takes the heavy cases (weekly review, plan generation). A Claude backend comes only for a feature both prove too weak for: the app sends logs and rule results to an endpoint that calls the Claude API with tool use (a Claude API service, not a custom agent), so the key never ships in the app.

Stack decided on 2026-10-28: **Python** (FastAPI, Postgres) for the backend, and Python for custom agents (Claude Agent SDK). Sync and accounts only when a feature needs them.

| Item | What changes | Why |
|---|---|---|
| **Backend skills scoped by `paths`** | Backend architecture, API, and data skills load only for backend folders; iOS skills stay scoped to the app and packages. | Neither side's rules leak into the other's context. |
| **Backend reviewer and research subagents** | A `backend-reviewer` (like `ios-reviewer`, preloading the backend skills) and, if needed, a read-only researcher for the backend code. No "architect" or "expert" personas: a subagent must add a different context, skill set, or fresh eyes, not claimed expertise. | Review and research are where subagents beat the main thread. |

## 4. Parked automation

| Item | Due when |
|---|---|
| **Routines** (scheduled cloud agents): weekly check for new Apple videos and docs not yet in `Knowledge/`; weekly audit of commits against the skills; re-check `Knowledge/` open questions after each OS beta | the repo is on GitHub and pushed regularly — routines only see pushed code |
| **Headless batch ingest** (`claude -p` once per WWDC URL into `Knowledge/`) | several videos arrive at once, or ingesting by hand feels repetitive |
| **Knowledge ingest skill** (`/ingest-video <url>`: `disable-model-invocation`, `allowed-tools` WebFetch/Read/Edit(Knowledge/**), one code file per video) | the next WWDC video is handed over for ingesting |
| **SwiftUI expert extracts** (from AvdLee/SwiftUI-Agent-Skill, MIT): a `swiftui-correctness` skill with the checklist, state, identity and invalidation rules; iOS 26/27 deprecated-API rows into `Knowledge/`; animation precedence into the global CLAUDE.md; trace scripts as a `performance-profiling` skill | the go-ahead is given, or a SwiftUI performance or state bug shows up |
| **Redact-secrets hook** (PreToolUse `updatedInput` swaps keys and tokens for placeholders) | the project gains a backend, a third-party model package, or any API key or token |
| **Commit guard fails closed** (`"onFailure": "block"`) | the commit guard must never fail open |
| **Block shell `xcodebuild`** (PreToolUse) | an agent reaches for `xcodebuild` in Bash |
| **16 pt gutter check** (PostToolUse on `*View.swift`) | a wrong gutter value slips into a view |
| **`git add -A` → scoped paths** (PreToolUse `updatedInput`) | staging catches files that weren't meant to be staged |
| **Instructions-loaded audit** (log which skills and CLAUDE.md loaded each session) | investigating a skill deviation ("did the skill even load?") |
| **flow-reviewer subagent** (reviews a logging flow against CLAUDE.md §2–4: tap count, screen density, defaults; read-only, structured output) | the first real logging flow is built |
| **Personal plugin** (extract the generic parts of the setup into a plugin repo with a marketplace manifest) | a second project starts using the setup |

## 5. Custom agents

Custom agents (Claude Agent SDK, Python) are goal 2 in [README.md](../README.md) and must not be skipped: each candidate below gets built when its trigger appears. **Fallback:** if none exists by 2027-01-15, recommend building the first one anyway (the PR review bot, or whichever trigger is closest).

| Agent | Job | Due when |
|---|---|---|
| **PR review bot** | Runs on each PR in CI, checks the diff against the project skills, posts a comment-only review; never approves or merges | the repo is on GitHub and work goes through PRs |
| **Knowledge ingest agent** | Takes a video or docs URL, writes the `Knowledge/` entry and code file, opens it for review | several videos queue up, or the headless ingest item is due |

Every custom agent ships with its tools, guardrails (what it may never do), and an eval set, and lives in its own folder with its own README.

## 6. Size budget

Guile-scale failure mode: the agent system outgrew the product and nobody could maintain it. These limits keep it reviewable by one person. No ratio to product code: the setup is a fixed cost built up front, so a ratio says little early on. Measured on 2026-10-28: ~1,200 lines of rule text (CLAUDE.md, skills, hooks) against ~9,000 lines of Swift.

| Measure | Limit |
|---|---|
| Rule text (CLAUDE.md + skills + subagent files) | ≤ 3,000 lines total |
| One skill's `SKILL.md` | ≤ 200 lines; the rest goes to reference files |
| Hooks | each ≤ 60 lines; a longer one becomes a tested script |
| Custom agents | counted as product code: own tests and evals, reviewed like app code |
| Every addition | names the failure it prevents; a rule that never fires in 3 months is a deletion candidate |

**Pruning pass:** when a limit is crossed, or every 3 months, review the setup and delete or merge before adding. A **size check script** (lines per category vs. limits) is due the first time a limit is crossed.
