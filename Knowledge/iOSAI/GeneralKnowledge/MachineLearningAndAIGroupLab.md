# Machine Learning & AI Group Lab (WWDC26)

Q&A session with engineers from the Core AI, Foundation Models, Evaluations and MLX teams. No code; this is guidance, trade-offs and rules of thumb straight from the framework teams. Project-agnostic. Items marked ⚠️ are stated loosely in the session and unconfirmed elsewhere.

**Source:** WWDC26 session 8016 "Machine Learning & AI Group Lab" · https://developer.apple.com/videos/play/wwdc2026/8016/
**Related:** [`../FoundationModels/`](../FoundationModels/README.md) · [`../CoreAI/`](../CoreAI/README.md) · [`../ImageUnderstanding/`](../ImageUnderstanding/README.md)

---

## 1. On-device model vs Private Cloud Compute — how to decide

| | On-device `SystemLanguageModel` | `PrivateCloudComputeLanguageModel` |
|---|---|---|
| Context | **4K** tokens | **32K** tokens |
| Offline | yes | no |
| Reasoning | no | yes, with a configurable level |
| Latency | no network hop | with a good connection the round trip is not the expensive part; tokens/sec is comparable, so latency alone rarely decides |

- The team's primary answer: **decide with evaluations, not intuition.** Because switching models is one line (`if` statement or a dynamic profile), instantiate the same feature twice, run both against the same evaluator suite, and compare in Xcode's side-by-side report.
- Even when PCC wins, the **offline fallback is on-device**, so measure how the feature behaves there too.
- **Dynamic profiles** are the mechanism for using both inside one feature: route or do simple steps on-device, escalate to PCC for complex ones, sharing context.
- The Foundation Models **Instrument** now reports round-trip latency, token budgets and more.

## 2. Model updates and prompt regressions

- The **on-device model only changes with an OS update** (about two big updates a year, both visible during beta). There is no silent push.
- The **PCC model can change independently**; the team gave no version identifier. ⚠️
- Guidance: treat model change as a given. Keep an **evaluation suite in the test suite**, rerun it on each OS beta, compare old vs new runs, then adjust prompts or tools.
- **Don't write OS-version-conditional prompts.** Prefer prompts that are specific but not hyper-tuned to one phrasing, so they hold across versions.
- Updates are meant to improve quality; evals also catch positive changes.
- Report use cases that regress during beta through Feedback Assistant.

## 3. Running the LLM outside the foreground

- The on-device model **can run in widgets, App Intents and background tasks** on iOS.
- On iOS it is **rate-limited by system conditions**: foreground, user-interactive work (a game, the camera) takes precedence. A rate-limited request throws a **specific error**; the correct response is to **retry later**, not to surface the error to the user.
- The system keeps **one copy of the model in memory** shared across apps; apps compete for it.
- **macOS does not rate-limit** the model, foreground or background (QoS still applies).

## 4. Adapting models to your app and data

A spectrum, cheapest first:
1. **Prompt + in-context data.** Pull the user's data into the prompt (with consent). Often enough; on-device keeps the data local.
2. **Tools.** Add capabilities the model lacks.
3. **Swap the model** (PCC, a Core AI model, a server model via the `LanguageModel` protocol).
4. **Fine-tune / train** (MLX for training, Core AI to run it; Hugging Face and GitHub for base models). Adapter training exists for the system model's text side, not for diffusion models.

- Foundation Models **cannot generate images**; for that, bring a diffusion model.
- **Hill climbing:** make one change (prompt, tool, model, quantization), re-run evals, keep what raised the score. The Evaluations framework accepts any system with randomness, including image models and classic ML, as long as the output maps to a boolean or a scalar; a **model-as-judge evaluator** can score style or quality.
- **Sample generator** (Evaluations framework): produces synthetic text inputs with chosen variety and count, for building eval sets; pair it with your own model's outputs to grow a dataset.

## 5. When to use an LLM, and when not

**Good fits:** content extraction, generation, summarization, grammar and tone transformation, image description and extraction (OS 27), anything "ask the model" where a few hundred ms to seconds is fine.

**Poor fits:**
- **Real-time per-frame work** (video, camera feeds, trajectory tracking): use **Vision**.
- **Sub-millisecond needs** (ranking a thousand list rows): use a small classic model or plain code.
- **Specialized tasks with a dedicated API**: speech recognition, **Translation** (more languages than the LLM), Vision's 30+ analyses. The team's note: developers overlook these high-level frameworks.
- Context-heavy jobs that overflowed 4K before may now fit on PCC's 32K.

Panel line: the right tool for the task, not one model for everything.

## 6. Availability and graceful degradation

- `availability` API tells you up front whether the system model can run on this device. Respond per reason: guide the user to enable Apple Intelligence, **hide the entry point** rather than showing an error, or offer a different experience so nothing feels missing.
- `prewarm` loads the model when intent is likely (a view appears with a button that triggers the model), cutting first-request latency.
- **Fallbacks on unsupported devices** go through the `LanguageModel` protocol: a Core AI/MLX model, or a server model (the utilities package ships a Chat Completions-compatible implementation). The session/tool/transcript code stays identical; only the model instance changes.

## 7. Core ML vs Core AI

- **No migration mandate.** Core ML stays supported and still covers things Core AI doesn't (decision trees, sub-millisecond models).
- Core AI is where investment goes for **modern generative models**; for any generative experience currently on Core ML, Core AI is the recommended path.
- Both are asset-based, so one app can load a different asset and call a different API per OS version behind a thin wrapper, and switch when the user base has moved.

## 8. On-device model size limits (Core AI)

- **iOS rule of thumb: keep models under ~2 GB.** Larger models stress the whole system (switching apps, launching the camera), and iOS prefers the user's foreground intent over your app. Higher memory limits can be requested in some cases. ⚠️ Not a hard limit.
- macOS: profile against available memory; configurations vary widely, so size the model to the machine (a Mac mini and a Mac Studio need not run the same model).
- Quantization stretches the budget: ~2-bit gets roughly a **6B-parameter LLM under 2 GB** ⚠️ (pushing it). Tolerance to quantization differs by model type; selective quantization recovers accuracy (see Core AI session 325). Decide "bigger quantized vs smaller unquantized" with evaluations.
- Measure with the available-memory APIs and Instruments. Remember memory is shared with everything else in the app.
- macOS can go further: multiple Mac Studios linked over **Thunderbolt 5 RDMA** run frontier-scale models; **M5 GPU neural accelerators** raise MLX performance.

## 9. PyTorch → Core AI: what converts

- Anything expressible in PyTorch and exportable via `torch.export` converts, as Core AI supports the full **Core ATen** op set.
- Unsupported custom ops: provide a **custom lowering** expressed in torch ops, or wrap a group of ops in a **custom Metal kernel** when performance matters.
- Most models in `coreai-models` needed no custom work; exceptions are frontier models with novel attention mechanisms.
- Inference-only graphs often need additions the training graph lacks (e.g. KV caching); the repo's examples and the **Core AI agent skills** help with that translation.
- MLX's API mirrors PyTorch closely; thousands of Hugging Face models already run via MLX LM.

## 10. Bringing your own model as a coding-agent backend

- Xcode's agent mode talks to local models through MLX server (chat mode, and the newer **ACP** mode, which the team recommends). Core AI is inference-only and has no server layer; one would have to be built on the `LanguageModel` protocol (open to contributions).
- Stray end-of-message tags from a local model usually point at a **chat template / tokenizer configuration** problem; GitHub issues on the MLX or Foundation Models repos are the place to ask.

## 11. Learning path (panel's advice)

- Start by **building something**: `LanguageModelSession` + `respond` in an Xcode Playground (one-click Playground project this year) teaches prompting, tools and structured output.
- Then go deeper on how LLMs work: tokens, the decoding loop, constrained decoding, training.
- For classic ML: Swift Playgrounds' Core ML image-classifier lesson (dataset building → training → in-app use); PyTorch or MLX tutorials; project-based learning over starting with the math.
- Use a coding agent as a tutor, including with the Core AI skills.

## 12. Product philosophy — when AI should help vs stay out of the way

- Start from the experience you want, not from the API. **No AI for AI's sake**; you don't need to advertise that a feature uses AI.
- AI that gets in the way of what the user is doing is the wrong answer; the best integrations (keyboard, dictation) get the user from A to B faster, under the hood.
- Prototype, then decide. For rigor, write user stories, build eval data points from them, and let the scores say whether the feature is worth shipping.

## 13. Open questions

- A runtime model-version identifier (especially for PCC) — none mentioned.
- The exact error type for background rate limiting and recommended retry cadence.
- How to request higher memory limits on iOS for large Core AI models.
- Evaluations framework: API shape, Xcode report integration details, model-judge configuration.
- Sessions referenced but not ingested: the Evaluations framework sessions, "Build agentic app experiences" (ingested), MLX sessions (distributed inference, Xcode + open code), "Discover Swift enhancements in the Vision framework".
