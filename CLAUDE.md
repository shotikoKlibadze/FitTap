# FitTap — Project Constitution

The single source of truth for what this app is, who it's for, and what we will and won't build. Any feature, screen, or interaction that conflicts with this document is wrong by default.

## 1. What FitTap is

FitTap is an iOS app for logging fitness progress — all of it: gym lifts, cardio, running, MMA, CrossFit, and whatever else the user actually does.

The name is the thesis: **"tap your fitness."** Logging happens through the minimum possible number of taps. Every design and engineering decision is judged against that.

## 2. The core principle — minimum interaction

Logging a set, a run, or a session must cost the user as few taps as physically possible. **The app anticipates; the user confirms.**

Canonical example — logging weight:

- ❌ **Wrong:** user taps `1`, taps `0`, taps "Enter" → 3 interactions for 10 kg.
- ✅ **Right:** user is shown the most-used weights (5, 7.5, 10, 12.5, 15, 20…) and taps `10` → 1 interaction.

The same principle generalizes: pre-surfaced common values, smart defaults from history, one-tap repeats of the last set, sensible increments instead of free-form entry. Free-form input exists as an escape hatch, never as the primary path.

**The tap test:** before shipping any logging flow, count the taps. If a competitor's app does it in fewer, we're not done.

## 3. Who it's for

The normal person who takes fitness seriously, but not *that* seriously.

Not bodybuilders. Not competitive athletes. Not coaches.

Someone who trains consistently, wants to see progress, and does not want to manage a database of their own body.

Most existing apps fail this user: too many fields, too many metrics, too much on screen, and it becomes confusing. FitTap is the antidote. *"I care about my fitness, but NOT THAT MUCH."*

## 4. Design rules that follow from this

- **Screens stay calm.** A screen shows what matters now, nothing more. Density is a bug.
- **No metric without a purpose.** If a number doesn't change a decision the user makes, it doesn't earn screen space.
- **Defaults over configuration.** The app guesses well; the user corrects rarely.
- **Depth is opt-in.** Detail lives one level down, behind a tap — never spread across the surface.
- **Speed in the gym.** The primary logging path must work one-handed, mid-set, with sweaty hands, without thinking.

## 5. What FitTap does (scope)

### Now — v1 foundation

- Logging across all activity types: gym (weight × reps), cardio, running, MMA, CrossFit, etc.
- Three tabs: Home, Workout, Statistics.

### Later — planned, not now

- **Built-in AI coach/suggestions.** Observational nudges in plain language: *"You've been at this weight for a while."* / *"Time to increase reps."* / *"Drop the weight, raise the reps."* / *"You've hit the same muscle repeatedly — that's working against the build you're after."*
- **Nutrition & diet** — food and diet plans folded into the same logging model.
- **Apple Watch + Apple Health integration.**

Detailed feature plans live in `Planning/` — [FeaturePlanning.md](Planning/FeaturePlanning.md) for the app and [AIFeaturePlanning.md](Planning/AIFeaturePlanning.md) for AI features, and [AgentSystemPlanning.md](Planning/AgentSystemPlanning.md) for the agent setup. Check them before building or proposing a feature; they are plans, not commitments, and this document still wins on scope.

### Explicitly not building

- Anything that turns FitTap into a coaching platform, a social network, or a data console.
- Advanced/competitive-athlete tooling (periodization editors, RPE matrices, velocity tracking, macro-gram micromanagement).

## 6. Engineering workflow

- Compile check: `XcodeRefreshCodeIssuesInFile` on each file you edited (open the workspace once per session with `XcodeOpenWorkspace` first) — never shell `xcodebuild`. Run a full `BuildProject` only when the user asks, or when the change can't be checked per file (project or package wiring).
- Engineering rules live in `.claude/skills/` — they load automatically when relevant.
- Platform: **iOS 27+ only** (overrides any lower baseline elsewhere). Use iOS 27 APIs freely, including Foundation Models with the Private Cloud Compute model; no `@available` checks or fallbacks.
- Persistence: **SwiftData**.
- **Stage, don't commit.** After making code changes, stage them with `git add` — but never commit unless explicitly told to.
- **Done = it compiles.** After writing code, the only verification is the per-file compile check above — nothing more: no project builds, no preview renders, no launching or simulator checks, no screenshots, no tests, unless asked. The user checks the look and behavior.
- **No tests unless asked** — don't write or run tests unprompted (see README.md).
- **Answer short.** Keep answers as concise as possible — a few sentences or small bullets, a tiny example only when it helps. Expand only when asked ("expand on this").
- **Rule-making is system-building.** "Add that to the rules" means put the rule where it belongs (a skill, this file, a hook, a script, memory), not automatically here. Any change to the agent setup goes through the `skill-authoring` skill: strongest mechanism first, reusable wording.
- **Agent terminology.** **Subagents** are the agents defined in `.claude/agents/` and run inside Claude Code. **Custom agents** are standalone agent programs built with the Claude Agent SDK. Use these two terms exactly, in answers and in files.
- **Watch for agent-system triggers.** When work hits a trigger in [AgentSystemPlanning.md](Planning/AgentSystemPlanning.md) — branches or tickets, a second developer or agent, Linear or GitHub, CI, a backend, API keys, a second project, unattended or repeated work a custom agent could do — recommend the matching item in one line, then continue. Don't build it unasked; update the file when an item is built or dropped.
- **The agent setup is itself a deliverable.** The overall goal behind this project is in [README.md](README.md) — FitTap doubles as a reusable agentic-workflow system, so process quality counts as much as the app. A deviation from a skill is a process defect: address it without excuses, find why it happened, and fix the skill or process so it cannot recur.

