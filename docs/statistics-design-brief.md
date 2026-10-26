# Statistics Tab — Design Brief

Audience: design agent. This describes **what** the Statistics tab shows, **why** each element exists, and **what it must never become**. Visual language, spacing, and component choices are the designer's call — within the constraints below.

---

## 1. Context

FitTap is a minimal-tap fitness logger for someone who trains consistently but is *not* a data nerd. The constitution's rules bind this screen harder than any other, because statistics screens are where fitness apps bloat:

- **No metric without a purpose.** A number earns pixels only if it changes a decision the user makes.
- **Screens stay calm.** Density is a bug.
- **Depth is opt-in.** Detail lives one tap down, never spread across the surface.
- **Glanceable.** The top-level screen must answer its question in ~2 seconds with zero taps.

## 2. The job of this tab

The user makes exactly three decisions that data can inform:

| Decision | Section |
|---|---|
| "Am I training enough?" | Consistency |
| "Am I getting stronger?" | Progression |
| "Am I neglecting a muscle group?" | Balance |

The tab is one scrollable screen with these three sections, in this order. Nothing else. The screen's single success criterion: opening it answers **"am I doing okay?"** at a glance.

Everything on this tab is derived from data the user already logs (sets, reps, weight, failure flags, dates, muscle groups). The tab asks for **zero new input** — it is pure payoff for logging.

---

## 3. Section 1 — Consistency (top)

**Question answered:** am I training as much as I usually do?

**Content:**
- Workouts this week against the user's own norm — e.g. "3 workouts this week · you average 4". The comparison baseline is a rolling average of their own recent weeks (last ~8), never a goal they had to configure.
- A compact month grid (calendar-dot style): one dot per trained day, tinted by that day's focus if cheap to do. This is for the "wow, I've actually been showing up" feeling — scannable, not interactive-heavy. Tapping a dot may open that workout's summary (reuses the existing workout-summary surface).

**Deliberate exclusions:**
- **No streaks.** Streaks punish rest days and guilt-trip a user returning from vacation or illness. A rolling average is honest and calm. This is a hard exclusion.
- No "goal setting" or configurable weekly targets. Defaults over configuration — the baseline is their own history.

**Tone:** neutral-positive. The section reports; it never scolds. A low week renders exactly like a high week — the number itself is the information.

## 4. Section 2 — Progression (the heart of the tab)

**Question answered:** am I getting stronger?

### Surface (on the tab itself)

A list of the user's exercises, most-trained first. Each row shows only:

- Exercise name
- Current working weight, formatted per the exercise's weight semantics (per side / per hand / stack / bodyweight — the app already has `LoadDisplayFormatter` rules for this; the row must respect them)
- A direction indicator:
  - **↑** working weight increased within the recent window (~last 4–6 sessions)
  - **→** flat over that window
  - *nothing* when there's too little data — absence of a signal is itself calm, never show "no data" text per row
- Bodyweight exercises with no added weight show their rep count instead of weight (e.g. "Pull-Up · 12 reps →")

No sparklines, no percentages, no deltas on the surface. The row is a headline, not a chart.

The list shows roughly the top 5–6 exercises with a "See all" affordance. Cardio exercises do **not** appear in this list (see §6).

### Detail (one tap down — exercise detail screen)

Tapping a row opens the single most important screen of the feature: **working weight over time** for that exercise.

- **One chart.** X = time (sessions, not calendar days — gaps between sessions don't stretch the line). Y = working weight (or reps, for bodyweight exercises).
- **Failure flags render as dots on the line** at the sessions where they occurred. This is the killer detail: a flat line with no failure dots *visually says* "you're ready to go up in weight" — the chart is the AI coach's UI before the AI exists. A flat line peppered with failure dots says "hold." The design should make this read instantly: clean sessions vs. flagged sessions must be distinguishable at a glance without a legend-hunt.
- Time range: default to something like last 3 months; a simple range toggle (3M / 1Y / All) is acceptable, nothing more granular.
- **Personal best**, one line, below or above the chart: heaviest weight × reps ever logged (e.g. "Best: 25 kg × 8 · Mar 12"). Auto-derived. This is the emotional payoff line — give it warmth but not confetti.
- **Last session recap**, one line: what they did last time (same format as the logging screen's "Last:" context, for consistency).
- Optional, further down: plain list of recent sessions for this exercise (date, sets). This is the depth-behind-depth; keep it visually quiet.

**Deliberate exclusions (hard):**
- No estimated 1RM. No tonnage/total-volume charts. No volume-per-muscle-group analytics. No rep-range distribution. These are bodybuilder/coach metrics; they change no decision this user makes.
- No multi-line comparison charts, no overlays of multiple exercises.

## 5. Section 3 — Balance (bottom, small)

**Question answered:** am I neglecting something?

**Content:** the muscle groups (same set and icons as the Workouts tab) with a lightweight recency/volume signal over the last ~4 weeks — e.g. each group's icon with a session count, where a neglected group is visually dimmed or quietly marked.

**Design intent:** this is *not* a chart to study. It exists so that "Legs: 1 session in 4 weeks" is noticeable in half a second while everything that's fine stays visually silent. Invisible-when-not-needed applies: a well-balanced month should make this section nearly boring.

Tapping a group can go to that group's exercise list (Workouts tab surface) — optional, low priority.

**Exclusions:** no radar/spider charts, no percentage splits, no "optimal balance" prescriptions. The app surfaces the fact; the user draws the conclusion. (Prescriptive nudges are the future AI coach's job, not this tab's.)

## 6. Cardio

Cardio doesn't fit the strength progression model — don't force it. Cardio gets one compact element (placement at designer's discretion, likely within or near Consistency):

- Total cardio minutes this week and this month (e.g. "Cardio: 85 min this month").
- Optionally per-activity detail one tap down (minutes over time for Running, etc.) — same one-chart philosophy, low priority for v1 of this tab.

No pace analytics, no distance PRs, no zones.

## 7. Empty and sparse states (design these explicitly)

This tab is useless on day one and must not look broken:

- **Zero workouts ever:** the tab shows a single friendly explainer — "Statistics build themselves as you log" — with nothing fake. No empty chart skeletons, no grayed-out dashboards promising future metrics.
- **1–3 workouts:** Consistency can already render (this week's count; month grid with a few dots). Progression rows render name + working weight but no direction arrow. Exercise detail shows the sessions as points without pretending there's a trend. Balance can render counts.
- **Returning after a long gap:** nothing punitive. The month grid simply shows the gap; the weekly average recalculates. No "you lost your streak"-type messaging anywhere, ever.
- **Single-session exercise:** detail screen shows the one data point + PB line (which equals it). Must not render a degenerate one-point "chart" awkwardly.

## 8. Interaction budget

- Tab open → "am I doing okay?" answered: **0 taps**.
- Any specific exercise's full story (trend + failures + PB): **1 tap**.
- Everything else (full exercise list, old workout summaries, cardio detail): **2 taps max**.

If a design needs a third level of depth or a settings/configuration step anywhere, it's over budget — cut the feature instead.

## 9. Visual direction (constraints, not prescriptions)

- Native iOS 26, Liquid Glass era. Should feel like Apple made it — system materials, standard navigation, full dark-mode support.
- Use the project's design-system semantic tokens, not literal colors.
- One accent color does the work; charts are near-monochrome with the accent for the line and a single distinct treatment for failure dots. No rainbow dashboards.
- Numbers are the heroes — typography over illustration. Charts support the number; they don't replace it.
- Swift Charts is the expected implementation substrate for the line chart; design within what it does naturally.

## 10. Summary of hard exclusions

Streaks · configurable goals · estimated 1RM · tonnage/volume analytics · rep distribution · radar charts · multi-exercise overlays · body measurements/weight tracking (not in scope) · badges/gamification · any metric requiring new user input · any prescriptive "you should..." copy (reserved for the future AI coach).
