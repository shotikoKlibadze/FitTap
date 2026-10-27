# Coding Intelligence, Machine Learning & AI Group Lab (WWDC26)

Q&A session with engineers from Xcode, Foundation Models, Evaluations, Core AI and MLX. No code; guidance and trade-offs from the framework teams. Project-agnostic. Items marked ⚠️ are stated loosely in the session and unconfirmed elsewhere.

**Source:** WWDC26 session 8121 "Coding Intelligence, Machine Learning & AI Group Lab" · https://developer.apple.com/videos/play/wwdc2026/8121/
**Related:** [`MachineLearningAndAIGroupLab.md`](MachineLearningAndAIGroupLab.md) (overlapping Q&A) · [`../FoundationModels/`](../FoundationModels/README.md) · [`../CoreAI/`](../CoreAI/README.md)

---

## 1. Which framework: Foundation Models vs Core AI vs Core ML vs MLX

A ladder, top down:
1. **Foundation Models** — any LLM task. Start with the system model; evaluate; step up to PCC; then plug in a custom model (Core AI, MLX, server) through the `LanguageModel` protocol with a one- or two-line switch. Everything else stays the same.
2. **Core AI** — non-LLM neural networks (diffusion, segmentation), or a custom/open-source model you ship, with production SLAs and guarantees. Apple asks that **everything new with neural networks go to Core AI**.
3. **Core ML** — stays supported, now focused on traditional ML (decision trees and the like).
4. **MLX** — research, experimentation, distributed inference on Macs, and **on-device training** (unique to MLX this year; e.g. training an adapter for Foundation Models).

Panel's refrain: why go remote or bring your own model if the on-device model already covers the use case; evaluations tell you.

## 2. Context window facts

- On-device: **4,096 tokens, shared between input and output** (4,000 in → at most 96 out).
- PCC: **32K**, also a shared budget.
- Need more: plug in an MLX/Core AI/server model via the protocol; some go to about a million tokens.
- An **image attachment costs roughly 200 tokens** on the on-device model (from session 8011; measurable with Instruments).
- Tools added for budgeting: `contextSize` and token counting (26.4), `response.usage` with input/output/cached/reasoning counts (27).

## 3. Background execution and rate limits

- On-device model runs in background tasks, including when the device is locked ⚠️ (the panel says "yes, in a background task"). Under system load it throws a **rate-limited error**; wait and retry. Output quality is unaffected; only timing is.
- macOS: no rate limiting while the app is in the foreground.
- PCC has a second kind of limit: **too many requests in a short period**, surfaced as a **different error type**, so the two can be told apart. (Session 8011 adds: the PCC model exposes a **quota property** to check how close you are, and a quota-exhaustion error per prompt.)

## 4. Mixing models in one agentic flow — privacy boundaries

- **Dynamic profiles** route declaratively between system, PCC and third-party models; the declarative shape makes it clear which model handles which step. Design hand-offs around performance, privacy and (for third-party) cost.
- **Baton-pass** = shared context; the receiver sees everything and finishes the answer. Use only when the whole transcript may be shared (same trust level, or Apple models only).
- **Phone-a-friend** = a tool opens a **short-lived session** that sees only the question; the parent restates the answer. Use when handing to a model with a **weaker privacy guarantee**. Bonus: it's an extra context window; you can even "phone yourself".
- **Profile modifiers** bridge context sizes: keep the last N entries, drop used tool calls, or summarize. They are **stateless transforms (views)**, so bouncing back to PCC restores the full context.

## 5. Context management best practices (on-device especially)

- After a tool call has produced a response, **drop the tool call and its output**; the answer is usually all that's needed.
- Drop or **compress older entries**. The open-source **FoundationModelsUtilities** package has a **summarize-history modifier**: at each prompt, if the transcript exceeds a size you set, it collapses it to one summary entry. Its prompt is **overridable** (verbose vs concise summaries), as is every prompt the API bakes in.
- Utilities and dynamic profiles work with **any `LanguageModel` backend**, not only Apple's.
- **KV-cache trade-off:** letting context fill keeps latency low until one big invalidation; trimming after every response means smaller, more frequent invalidations. Also an **accuracy** question: long, stale context can distract the model. Decide with evaluations: A/B the strategies as different profiles over one dataset and use Xcode's compare view.
- **Split independent tasks into separate sessions** so each gets the whole window; or call the same model as a tool.
- Newer architectures (sliding-window, linear attention) and configurable reasoning (PCC: light / moderate / deep) change how fast context fills; reasoning tokens are the first thing dropped.

## 6. Bringing your own model

- The `LanguageModel` protocol: one unified API for prompting, tool calling and structured output over any backend. Google's and Anthropic's packages exist; MLX and Core AI packages are open source; the framework itself is going open source, so the source is a reference for custom providers.
- Apple ships an open-source **skill** that helps a coding agent implement the protocol; point it at the MLX and Core AI repos for examples, then verify with evaluations.
- Local models in Xcode's agent: use **ACP** (agent client protocol) rather than plain chat; agents can run sub-agents, manage state and do file I/O over long loops. Stray end-of-message tags point at chat-template/tokenizer config.

## 7. Guardrails vs refusals

- `permissiveContentTransformations` ⚠️ (name recalled live) on the system model lets emotionally charged **input** (journal entries, grief) pass the input guardrail.
- The model may still **refuse in natural language**; with guided generation that surfaces as a **refusal error**, which is the model's alignment, not the guardrail.
- **Guardrail violation** is a separate moderation model over input and output, caught as its own error. Neither applies to third-party models.
- Guardrails were retrained this year; false positives should be far fewer. A model-judge evaluator with a safety rubric (optionally run on PCC) can audit borderline prompts.

## 8. Vision vs Foundation Models for images

- Same thing every time, well-understood, needs efficiency and testability (detect this object, read this barcode) → **Vision**.
- Different every time, needs semantic understanding, or driven by a user's natural-language prompt → **Foundation Models**, now with Vision-powered `OCRTool` and `BarcodeReaderTool` inside it.
- Analogy from the panel: Foundation Models is a 3D printer; a dedicated model is a production line. Same logic for **Translation** (more languages, fixed in/out) vs asking the LLM to translate "like a pirate".

## 9. Models cannot be shared across apps

- One model file serving many apps is **not possible** on iPhone: sandboxing, resource contention, and each app's own quantization/quality trade-offs.
- Exception: **same developer, same app group** can share downloaded weights and, with Core AI's model cache, the cached specialization; memory-resident copies are still per app.
- The system Foundation Model is the one truly shared model: part of the OS, no app-size cost.

## 10. Coding agents and your codebase (Xcode team's advice)

- Agents learn by **search** and by **notes**. They copy the style they see in the project out of the box.
- Keep the always-loaded file (`AGENTS.md` / `CLAUDE.md`) **short**; it's in every query. **Reference** style guides and area-specific markdown from it, and have the agent read them on demand.
- Have the agent **write down assumptions and fixes** as it goes (e.g. "document what solved that crash") so later runs avoid the same pattern.
- When a new model ships, **try starting with no instructions**; the skill is knowing which instructions you still need.
- Xcode's agent can **search Apple documentation**, so even an older local model learns new APIs; it can drive the **Simulator** (tap, swipe, type, read the accessibility tree and screenshots), find bugs over hours, and then write the UI tests.
- Testing pyramid with agents: thousands of fast unit tests, a few hundred integration tests, a handful of UI tests; agents help restructure code to be testable.

## 11. Evaluation philosophy

- **Start with evaluation**; it is the living specification of the feature (core cases, headroom, edge cases). "Evaluation-driven development" — formative assessment, as in teaching.
- Workflow: a small curated dataset → expand synthetically → run → find weak spots → change → compare → repeat (hill climbing).
- Most "can the model do X?" questions have no general answer; the framework exists so each app gets its own.

## 12. Open questions

- Exact name and semantics of the permissive-input guardrail option.
- The rate-limit and quota error types and the PCC quota property.
- Whether background execution works while the device is locked, and for how long per wake.
- The summarize-history modifier's API in the utilities package.
- Sessions referenced, not ingested: Evaluations framework sessions, "Bring an LLM provider to the Foundation Models framework", MLX + Xcode agent session.
