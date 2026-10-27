# Apple Intelligence Group Lab (WWDC26)

Q&A session with engineers from Foundation Models, App Intents, Siri and the Evaluations framework. No code; guidance from the teams. Project-agnostic. Items marked ⚠️ are stated loosely in the session and unconfirmed elsewhere.

**Source:** WWDC26 session 8011 "Apple Intelligence Group Lab" · https://developer.apple.com/videos/play/wwdc2026/8011/
**Related:** [`MachineLearningAndAIGroupLab.md`](MachineLearningAndAIGroupLab.md) · [`CodingIntelligenceMachineLearningAndAIGroupLab.md`](CodingIntelligenceMachineLearningAndAIGroupLab.md) · [`../FoundationModels/`](../FoundationModels/README.md)

---

## 1. The new Siri (iOS 27) and how apps take part

Three pillars: Siri understands **on-screen content**, takes **actions across apps**, and holds **multi-turn conversations** about an app's content. An LLM parses requests, so phrasing is flexible.

Integration paths, from most to least Apple-provided:

| Mechanism | What it is | When |
|---|---|---|
| **App schemas** (`AppSchema.*`) | Apple-designed, fine-tuned intent and entity shapes per domain (messages, calendar, timers, books, …) | required for the new Siri AI integration; pick and choose per capability, mix domains freely |
| `system.search` / `system.open` | generic schemas: route a Siri request into your app's search, or open an indexed entity | e-commerce, food ordering, anything searchable; apps with no domain fit |
| **Custom App Intents + App Shortcuts** | your own intents, with phrases | hero actions with a memorable phrase; functionality outside any schema |
| **Indexed entities** (`IndexedEntity`) | donate content to the **semantic index** so Siri can retrieve it ("a book by that author") | pair with a schema for the best experience; also works for custom entities (Spotlight results, deep links) |
| **View annotations** / `NSUserActivity` | mark on-screen SwiftUI content with schema-conforming entities | lets Siri act on what's visible |
| **Intent donations** | report in-app actions so Siri learns habits ("message Dan" → the app you always use) | personalization |
| **Transferable** | declare which data your app exports and imports, by fidelity | cross-app data flow under your control |

- Schemas trade flexibility for **consistency, privacy, safety and localization**: Apple trains the phrases, adds confirmations where needed (sending money, deleting a shared event via the new entity-ownership API), and localizes. Adopting a schema also means **less code** than a custom intent.
- Why not markdown "skills" like chat assistants? The panel's answer: consistency across apps, built-in safety behaviours, and Apple-scale localization.
- **Cross-app orchestration:** a new system orchestrator runs intents across apps. Apps don't invoke each other's intents directly. Data indexed by your app is visible to **the system only**, never to other apps; Transferable is the opt-in sharing path.
- Multi-turn follow-ups about your entities: yes, through schemas.
- Availability: iPhone, iPad, Mac, visionOS. **Not HomePod** (existing App Shortcuts still work there). Test across devices, including **AirPods** and Watch; intent `dialog` supports full vs supporting modes for screenless contexts.
- **App Intents testing framework** (new): unit-test intents, entities, queries, Spotlight integration in CI.
- Spotlight-tool retrieval inside a Foundation Models session is **sandboxed to the donor app**, even within an app group.

## 2. Foundation Models notes from this lab

- **Rate limiting:** none in the foreground. In the background, throttled under heavy load; catch the rate-limited error and retry later.
- **Error model (27):** the `LanguageModel` protocol brings a common `LanguageModelError` for cases shared by all backends (rate limits, refusals). The PCC model additionally exposes a **quota property** (how close to the limit) and a **quota-exhaustion error** per prompt.
- **Guardrail violations** you can't explain: audit the prompts with a **model-judge evaluator and a safety rubric** (1–4 scale), optionally on the larger PCC model.
- **Video:** not a first-class input. The protocol declares per-model capabilities (vision is one); PCC adds reasoning levels **light / moderate / deep**. For video, build a **tool** that uses other frameworks to extract a transcript or description, then feed text to the model; custom modalities can be carried via the protocol's custom segment API.
- **Image tokens:** an image attachment costs about **200 tokens** on the on-device model; the 4,096 budget is otherwise unchanged. Instructions and prompt can use the whole window; a large input with a small output is fine.
- **Small-model prompting:** be more precise, try synonyms, include examples; hill-climb the phrasing with evaluations.
- Context between models: `historyTransform` plus the utilities package's summarization keep a 32K transcript usable at 4K.

## 3. Evaluations framework notes

- Evaluates **any stochastic system**, not only Foundation Models; the one piece that needs a Foundation Models transcript is the **tool-call evaluator** (assertions on which tools were called, in what order, with what argument values). A generic transform for other providers is in progress.
- Reports are JSON, exportable, with Xcode visualizations; usable for research benchmarks, not just product work.
- Instruments shows tool calls live; evaluations show them in batch.
- Three sessions: intro, advanced (synthetic data), hill climbing.

## 4. Image Playground

- Photorealistic output: yes, via `ImagePlaygroundStyle.all` ⚠️ (name as spoken). Generation runs on **PCC**, so it **always needs a network connection**; no on-device fallback.

## 5. Open questions

- Exact names: PCC quota property and error, `LanguageModelError` cases, the Image Playground style parameter.
- Which app-schema domains exist in 27 (no finance domain was noted) and the system domain's full list.
- Background-wake time budget for the on-device model.
- Sessions referenced, not ingested: the App Intents sessions (Antonio's Siri-experience session, the intents-testing session), the Image Playground session, the Evaluations sessions.
