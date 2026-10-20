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

### Explicitly not building

- Anything that turns FitTap into a coaching platform, a social network, or a data console.
- Advanced/competitive-athlete tooling (periodization editors, RPE matrices, velocity tracking, macro-gram micromanagement).

## 6. Engineering workflow

- Build: use the iOS Simulator MCP server's `build` tool — never shell `xcodebuild`.

