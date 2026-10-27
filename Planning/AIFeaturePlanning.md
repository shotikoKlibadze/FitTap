# AI feature plans

Candidate AI features for FitTap and the Apple technology each one maps to. A working list, not a commitment. Scope and priorities still answer to [CLAUDE.md](../CLAUDE.md). Technology details live in [Knowledge/iOSAI/](../Knowledge/iOSAI/).

**Governing rule:** numbers and decisions come from Swift rules (later, a small Core ML/Core AI model). The LLM phrases, interprets and extracts. It never decides a weight, a rep count or a plan on its own.

## Feature list

- **On-device Foundation Models:** coach nudges · post-workout summary · free-text logging · exercise matching and tagging · photo logging · ask my history
- **Private Cloud Compute:** weekly / monthly review · workout generation · diet plans (later) · dynamic profiles tying these together
- **Watch + HealthKit:** session interpretation · auto session boundary detection
- **Core AI, own models:** progression model · set detection from Watch motion · custom LLM as a fallback

---

## On-device Foundation Models
Free, private, offline, fast. Best for short structured output.

| Feature | What it does | Technology |
|---|---|---|
| **Coach nudges** | Rules engine detects a plateau, a progression opportunity or repeated muscle use. The model writes one plain-language sentence. | `@Generable` output with a fixed shape; `SystemLanguageModel`; prewarm when the workout tab opens |
| **Post-workout summary** | One line after a session: "PR on bench, 2nd run this week." | `streamResponse`, shown while the session is still ending |
| **Free-text logging escape hatch** | "5x5 squat 80, then 20 min row" → structured sets and cardio entries | `@Generable` extraction into existing models |
| **Exercise matching and tagging** | "DB press" → `dumbbellBenchPress`; muscle-group tags for user-created exercises | content-tagging adapter (`useCase: .contentTagging`) |
| **Photo logging** | Photo of a treadmill or rower display → cardio entry | vision input (iOS 27) + `OCRTool` |
| **Ask my history** | "When did I last do deadlifts?" answered from the user's own logs, offline | Spotlight search tool (local RAG) over indexed workouts |

## Private Cloud Compute
Reasoning, 32K context, no API keys. Only for jobs the on-device model can't do.

| Feature | What it does | Technology |
|---|---|---|
| **Weekly / monthly review** | Trend analysis over a month of logs, a few sentences, in the Statistics tab | `PrivateCloudComputeLanguageModel`, `reasoningLevel: .deep` |
| **Workout generation** | User names a muscle group ("legs") → a full proposed session, built the way *they* usually train: exercises from their history, last-used weights and rep ranges, their usual set counts and exercise order, spaced against recent sessions and rest days. Rules validate every load before it's shown; the model picks structure and explains why, never invents numbers | PCC + a tool that reads `WorkoutStore` (history, per-exercise last weights, session dates for rest-day spacing) |
| **Diet plans** (later) | Plans folded into the same logging model | same session, baton-pass from "review" to "plan" |

**Dynamic profiles** tie these together: on-device profile for daily nudges, PCC profile only when the user opens the review screen. History transforms trim the transcript when switching back to the small model.

## Watch + HealthKit
The Watch logs. The phone thinks. Foundation Models exists on watchOS 27 only through PCC, so no on-device AI on the wrist.

| Feature | What it does | Technology |
|---|---|---|
| **Session interpretation** | HR zones and rest intervals from HealthKit merged with logged sets; the model explains: "you rested longer than usual, hence the drop on set 4" | rules engine over HealthKit samples + on-device FM phrasing |
| **Auto-detect session boundaries** | Workout started / ended inferred from Watch motion and HR, so the user doesn't tap Start | rules first; a small Core AI model later |

## Core AI — own models
Only once there is enough logged data to train on.

| Feature | What it does | Technology |
|---|---|---|
| **Progression model** | Predicts the next weight or reps from the user's own history; replaces hand-written rules over time | small PyTorch model → `coreai-torch` → `InferenceFunction.run` |
| **Set detection from Watch motion** | Accelerometer windows → set started / ended / rep count. The biggest tap-saver in the app | Core AI model on the Watch; stateful inference if sequential |
| **Custom LLM** (fallback) | Only if Apple's model can't phrase fitness language well enough | Qwen 0.6B via `CoreAILanguageModel` in the same `LanguageModelSession` |

---

## Suggested order
1. **Coach nudges** — smallest, matches the constitution exactly, and every piece (rules engine, `@Generable` shapes, availability handling, prewarm) is reused by everything else.
2. Post-workout summary and free-text logging.
3. Weekly review on PCC, then dynamic profiles.
4. Watch integration and session interpretation.
5. Own models, once data exists.
