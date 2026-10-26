# Foundation Models framework

Reference notes on Apple's Foundation Models framework, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data, since the APIs ship after most knowledge cutoffs.

API names and shapes are confirmed against Apple's published sample code (see `code/`). Items marked ⚠️ are unconfirmed.

**Platforms:** iOS, iPadOS, macOS, visionOS (26+) · watchOS 27+ (Private Cloud Compute only)
**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title, holding Apple's published snippets with timestamps. A file's presence means that session's transcript and code are ingested.
**Sources:** WWDC26 242 "Build agentic app experiences with the Foundation Models framework" · WWDC25 286 "Meet the Foundation Models framework" · WWDC25 301 "Deep dive into the Foundation Models framework" · WWDC25 259 "Code-along: Bring on-device AI to your app" · WWDC26 241 "What's new in the Foundation Models framework"

---

## 1. What it is

A Swift API around language models. Its core is a **stateful `LanguageModelSession`**, which is prompted for text, typed Swift values, or streamed snapshots. The model can also call app code through tools.

- The **default model** is Apple's on-device LLM, the one behind Apple Intelligence. It's private, works offline and is free. It's built into the OS, so it adds nothing to app size.
- **From OS 27** the same session API can be backed by the **Private Cloud Compute (PCC)** server model, local open models (Core AI, MLX), or third-party server models (Anthropic, Google), all through the `LanguageModel` protocol.
- **From OS 27** the core framework is **open source** and runs anywhere Swift runs, including Linux servers.

---

## 2. Capability catalog

| Capability | What it gives you | Typical uses | OS |
|---|---|---|---|
| Text generation | `respond(to:)` → `String` | free-form copy: summaries, rewrites, short messages | 26 |
| **Guided generation** (`@Generable`, `@Guide`) | the model returns a Swift type, with structure guaranteed | anything shown in UI or fed into code | 26 |
| Snapshot streaming | `streamResponse` → partially filled values over time | output longer than about a sentence; hides latency | 26 |
| **Tool calling** (`Tool`) | the model decides on its own to call app code for data or actions | personal or app data (contacts, calendar, app DB), fresh facts, actions | 26 |
| Dynamic schemas | output structure defined at runtime | user-defined or server-defined shapes | 26 |
| Multi-turn transcript | the session remembers earlier turns | chat, follow-ups ("make it shorter") | 26 |
| Sampling control | greedy (deterministic) or temperature | repeatable output (demos, tests) or more variety (games, ideas) | 26 |
| Content-tagging adapter | specialized model for tags, entities, topics | classification and extraction from user text | 26 |
| Custom adapters | train your own adapter (toolkit) | highly specialized domains with a dataset; heavy upkeep | 26 |
| Context size + token counting | the device's context size, token counts of prompts and transcripts | fitting history or prompts into the window | 26.4 |
| **Vision input** (image attachments) | images in prompts, any size or aspect ratio | understanding photos, screenshots, scans | 27 |
| **Private Cloud Compute model** | larger server model, 32K context, **reasoning** | harder reasoning, broader world knowledge, long context, watchOS | 27 |
| Reasoning levels | `contextOptions: ContextOptions(reasoningLevel:)` | better answers in exchange for extra compute and latency | 27 |
| `LanguageModel` protocol | swap the backing model (PCC, Core AI, MLX, Anthropic, Google, custom) | needs beyond Apple's models, or server-side Swift | 27 |
| Usage accounting | per-response `usage`: tokens, cached input, reasoning tokens | cost tracking with paid third-party models | 27 |
| System tools: `OCRTool`, `BarcodeReaderTool` | Vision-powered text and barcode reading as tools | labels, receipts, documents, packaging | 27 |
| System tool: Spotlight search | **local RAG** over a Core Spotlight index | answering from the user's own or the app's content | 27 |
| **Dynamic profiles** | one session that switches instructions, tools, model and generation options by state | agents with modes (analyze → plan), mixed models | 27 |
| `DynamicInstructions` | reusable, composable bundle of instructions + tools | a "persona" or expertise shared by several profiles | 27 |
| History transforms + session properties | per-prompt or permanent transcript editing, shared session state | long sessions, model hand-offs, summarizing, redacting | 27 |
| Lifecycle modifiers (`onResponse`, `onToolCall`) | run code at session events | updating UI/state, switching modes, trimming history | 27 |
| Tool calling mode | `.allowed` / `.disallowed` / `.required` | agent loops where every action is a tool call | 27 |
| Transcript error policy + mutable transcript | keep or revert transcript after errors; rewrite it when idle | cancel-and-resume flows, manual repair | 27 |
| Evaluations framework | statistical measurement of output quality | any shipped LLM feature; guards prompt changes | 27 |
| `fm` CLI + Python SDK | on-device and PCC models from the terminal or Python | trying prompts, scripts, data work | macOS 27 |
| FM utilities package (open source) | `rollingWindow`, `droppingCompletedToolCalls`, **`Skills`**, Chat Completions model | experimental building blocks, updated between OS releases | 27 |

---

## 3. Models

### On-device `SystemLanguageModel` (default)
- In the OS 26 generation it has about 3B parameters with 2-bit quantization. OS 27 ships a rebuilt model that is better at logic and tool calling.
- **Strengths:** summarizing, extracting, classifying, tagging, short generation, and rewriting text in a given style.
- **Weaknesses:** world knowledge and advanced reasoning. Apple describes it as a device-scale model that works best on tasks broken into small pieces, with facts supplied through tools.
- **Context is small and hardware-dependent.** `SystemLanguageModel().contextSize` (26.4+) reports it; `model.tokenCount(for:)` counts tokens. Observed values: 4,096 (`fm` on one Mac) and 8,192 (Apple's sample). → `code/WhatsNewInFoundationModels.swift`
- **Availability depends on Apple Intelligence:** the device has to be eligible, the user has to turn it on, and the model has to be downloaded. See §8.
- Adapters: `SystemLanguageModel(useCase: .contentTagging)` gives tags, entities and topics. With custom instructions and a custom output type it can also detect things like actions or emotions.

### `PrivateCloudComputeLanguageModel` (OS 27)
- The server model behind Apple Intelligence. It's much larger, has a **32K-token context** and supports **reasoning**.
- No accounts, auth or API keys. Apple stores no prompts, and outside researchers can verify that.
- Requires an **entitlement**. ⚠️ The process is in the "Building with Private Cloud Compute" session.
- **Cost:** no cloud API cost for developers under 2M first-time downloads. Each user gets a daily quota, and the quota is higher with iCloud+. ⚠️ Exact limits and quota-exceeded behaviour are unconfirmed.
- Makes Foundation Models possible on **watchOS 27**.
- Requires a network connection.
- Reasoning levels seen: `.light`, `.deep`. Deeper reasoning gives better answers at the cost of more compute. → `code/WhatsNewInFoundationModels.swift`

### Other `LanguageModel` implementations (OS 27)
- `SystemLanguageModel` and `PrivateCloudComputeLanguageModel` both conform to `LanguageModel`. So do these:
  - **`CoreAILanguageModel`** and **`MLXLanguageModel`** (open source) run local models on the Neural Engine or the Mac GPU.
  - **Anthropic and Google Swift packages** for their frontier models. The package is added, the model created and passed to the session. Nothing downstream changes.
  - A Chat Completions–compatible model (in the utilities package), or a custom implementation (see the "Bring an LLM provider…" session).
- With third-party server models, **auth and billing are the developer's responsibility.** Apple's guidance: no private keys in the binary; tokens fetched via OAuth and stored in Keychain.
- Billing is usually per token. `response.usage.input.totalTokenCount` / `.cachedTokenCount` and `response.usage.output.totalTokenCount` / `.reasoningTokenCount` report usage.

### Comparison

| | On-device | PCC | Third-party server |
|---|---|---|---|
| Privacy | data never leaves the device | Apple-verified, no prompt storage | provider's policy |
| Cost | free | free under 2M downloads; per-user daily quota | per token |
| Offline | yes | no | no |
| Context | ~4–8K | 32K | provider-dependent |
| Reasoning | no | yes | provider-dependent |
| Auth | none | entitlement | OAuth + Keychain |
| watchOS | no | yes (27) | — |

Dynamic profiles (§9) combine models inside one session.

---

## 4. Sessions, instructions, prompts

→ `code/MeetTheFoundationModelsFramework.swift, code/DeepDiveIntoFoundationModels.swift`

- Initializers: `LanguageModelSession(instructions:)`, `(tools:instructions:)`, `(model:)`, `(transcript:)`, `(profile:)` (27). Instructions can be a string or a builder that includes `@Generable` example instances.
- `respond(to:)` → `.content` is a `String`; `respond(to:generating:)` → `.content` is the given type; `respond(generating:) { prompt builder }` also exists.
- **Instructions** are the developer's: role, style, length and examples. **Prompts** can come from the user.
  - The model is trained to follow instructions over prompts, which helps against prompt injection. Apple states it is **not a guarantee**.
  - Apple's guidance: instructions stay mostly static, and untrusted user input is not interpolated into them.
  - Instructions are optional; sensible defaults apply when omitted.
- A **full example** in the instructions (a `@Generable` instance works, and the framework turns it into text) steers output strongly.
- **The session is stateful.** Each turn is added to `session.transcript`. The first entry is the instructions. The transcript is readable for debugging or for rendering chat UI.
- `session.isResponding` is true while generating. A prompt sent during that time conflicts with the one in flight.
- **Tokens cost latency.** The model processes every input token before it outputs anything, and every output token takes time. Shorter instructions, prompts and outputs are faster.

### Context-window overflow
- The error is `LanguageModelSession.GenerationError.exceededContextWindowSize`. Recovery paths Apple shows:
  - a new empty session, which loses all memory
  - a new session carrying **the instructions + the last successful response** (`Transcript(entries:)` → `LanguageModelSession(transcript:)`; entry 0 is the instructions)
  - a new session carrying the instructions + a **summary** of the transcript (the model itself can write the summary)
- OS 26.4+ exposes token counting, so overflow can be predicted. OS 27 adds `transcript.dropFirstInstructions()`; the utilities package adds profile modifiers for transcript management.

### Sampling (`GenerationOptions`)
- The default is random sampling, so the same prompt gives different output.
- `GenerationOptions(sampling: .greedy)` gives deterministic output for the same prompt and session state, but **only on the same model version**. An OS update can change it.
- `GenerationOptions(temperature:)`: lower means less variation (e.g. 0.5); higher means wilder output (e.g. 2.0).

---

## 5. Guided generation — `@Generable` + `@Guide`

Apple's primary mechanism for output consumed by code or UI. It uses **constrained decoding**, which masks out invalid tokens, so the structure is guaranteed with no parsing and no invented keys. Prompts become simpler, accuracy goes up, and inference gets faster.

→ `code/MeetTheFoundationModelsFramework.swift, code/DeepDiveIntoFoundationModels.swift`

- **Supported types:**
  - `String`, `Int`, `Double`, `Float`, `Decimal`, `Bool`, and arrays
  - nested `@Generable` structs
  - **enums, including associated values** (e.g. `case order(Coffee)` or `case complaint(String)`)
  - **recursive types**, which suit generative UI
- **Guides:**
  - numbers: `.minimum`, `.maximum`, `.range(1...10)`
  - arrays: `.count(3)`, `.maximumCount(3)`, plus guides on the element
  - strings: `.anyOf([...])` or a **regex** (`@Guide(Regex { … })`, RegexBuilder syntax)
  - `description:` works on anything and acts as a prompt tied to that field
- **Property order = generation order.** Fields declared later can depend on earlier ones. Apple notes summaries come out best when declared last. Order also sets streaming and animation order.
- `includeSchemaInPrompt: false` skips the auto-inserted schema, which means fewer tokens and lower latency. It is safe when the model already knows the format:
  - later same-type requests in the same session, or
  - instructions that contain a **full example** (for optional properties, examples both filled and `nil`).
  - The cost: `@Guide` descriptions are no longer sent.

### Dynamic schemas (structure known only at runtime)
- `DynamicGenerationSchema(name:properties:)` values are built from `DynamicGenerationSchema.Property(name:schema:)`. Property schemas: `DynamicGenerationSchema(type: String.self)`, `(arrayOf:)`, `(referenceTo: "Answer")` to **refer to other schemas by name**.
- `GenerationSchema(root:dependencies:)` validates them. It throws on broken references.
- `session.respond(to:schema:)` returns `GeneratedContent`; `content.value(String.self, forProperty: "question")` reads it. It's still constrained, so it never contains unexpected fields.

---

## 6. Streaming — snapshots, not deltas

→ `code/MeetTheFoundationModelsFramework.swift`

- `streamResponse(…generating: T.self)` returns an async sequence of **`T.PartiallyGenerated`** values. This mirror type is generated by the macro, and all its properties are optional.
- Each element is a complete **snapshot** so far, not a delta, so there's nothing to accumulate.
- Partially generated values are **Identifiable**, so `ForEach` works directly.
- Apple's notes on UI: fields arrive in declaration order; animations and `contentTransition` make text stream in smoothly; view identity matters when arrays are being generated.

---

## 7. Tool calling

→ `code/MeetTheFoundationModelsFramework.swift, code/DeepDiveIntoFoundationModels.swift`

- The model **decides by itself** whether to call app code, how often, and with what arguments.
- **Uses:**
  - **data:** personal data, app data, world knowledge, fresh info
  - **grounding:** it can cite sources, which cuts hallucination
  - **actions:** in the app, the system, or the real world
- **How a call flows:**
  1. The tools' names and descriptions go into the prompt **word for word**. Apple's guidance: short, verb-first names (`findContact`), one-sentence descriptions, no implementation details.
  2. Arguments are produced with guided generation, so tool names and arguments are always valid. `Arguments` is a `@Generable` struct; enum arguments restrict the model to known cases.
  3. `call(arguments:)` returns `ToolOutput` (OS 26; from `GeneratedContent(properties:)` or a `String`). OS 27 samples return `some PromptRepresentable` (a `String` works).
  4. The session **waits** for `call` to return. Its output goes into the transcript, and the model then writes the final answer.
- **Behaviour:**
  - Tools are fixed **when the session is created** and last for its lifetime. Exception: dynamic profiles, §9.
  - The tool instance is passed in, so the app owns its lifecycle. A `class` tool can keep state across calls (Apple's example: not picking the same contact twice).
  - **One request can call a tool several times, in parallel**, so `call` runs concurrently.
  - Inputs can come from the app (passed to the tool's init) and from the model (`Arguments`).
  - Context in the instructions, such as **today's date**, lets the model resolve phrases like "tomorrow" into arguments.
  - System permission prompts (Contacts, Calendar…) appear the first time a tool needs them. If denied, the model still generates, without that data.
  - Mentioning the tool or its categories in the prompt makes the model call it more often.
- Tools can also be fully **dynamic**, using runtime schemas for their arguments.
- **Privacy:** on-device tools over personal data (contacts, calendar, health) never send that data off the device.

### System tools (OS 27)
- `OCRTool`: structured text from images. `BarcodeReaderTool`: barcode contents. Both are backed by Vision. See "What's new in image understanding".
- **Spotlight search tool:** fully local **RAG** over the app's Core Spotlight index. See "LLM search using Core Spotlight".

---

## 8. Availability, errors, languages

→ `code/MeetTheFoundationModelsFramework.swift, code/DeepDiveIntoFoundationModels.swift`

- `SystemLanguageModel.default.availability` is either `.available` or `.unavailable(let reason)`. The reasons and the UX Apple shows for each:

| Reason | UX in Apple's sample |
|---|---|
| device not eligible | feature hidden; non-AI fallback shown |
| Apple Intelligence not enabled | explanation of why it's unavailable; user decides whether to turn it on |
| model not ready (downloading) | "Try again later" |

- **Testing:** the Xcode **scheme option "Foundation Models Availability"** fakes each state without turning Apple Intelligence off.
- **Simulator:** works if the Mac runs the latest macOS with Apple Intelligence on. Timing differs from real devices.
- **Errors:**
  - guardrail violation
  - `LanguageModelSession.GenerationError.unsupportedLanguageOrLocale`
  - `exceededContextWindowSize`: see §4
- **Language support:** `SystemLanguageModel.default.supportedLanguages.contains(Locale.current.language)` reports whether the user's language is supported.
- OS 26.4 and 27 reduce guardrail false positives.

---

## 9. Dynamic profiles — agentic sessions (OS 27)

→ basics `code/WhatsNewInFoundationModels.swift` · in depth `code/BuildAgenticAppExperiences.swift`

Apple frames the problems these APIs solve as **context management** (keeping long sessions inside a model's window) and **boundaries** (which model, with what capability, cost and privacy, handles which step). A profile is Apple's unit of "agent": a configuration with a goal and a set of capabilities.

### Building blocks
- **`Profile`** = instructions + tools + modifiers. Modifiers seen: `.model(_)`, `.temperature(_)`, `.reasoningLevel(_)`, sampling mode, `.historyTransform`, `.toolCallingMode`, `.transcriptErrorHandlingPolicy`, `.onResponse`, `.onToolCall`.
- **`LanguageModelSession.DynamicProfile`**: a `body` that resolves to **one active `Profile`** per prompt. The body is **re-evaluated on every prompt**, so a change in observable app state swaps the session's persona ("switching hats") while the **conversation history is kept**.
- **`DynamicInstructions`**: a reusable, composable group of instructions + tools (e.g. an "OrigamiExpert"). Nesting concatenates. Conditionals inside the body include pieces only when relevant.
- **`LanguageModelSession.DynamicProfileModifier`** + an extension on `DynamicProfile` packages a configuration for reuse (e.g. `.droppingCompletedToolCalls()`).
- **`LanguageModelSession(profile:)`** creates the session.

### Transcript and history
- The transcript is the model's context. **History** = the transcript minus the instructions entry.
- **`historyTransform`**: a per-prompt, per-profile, **lossless** edit; the stored transcript is untouched. Used to fit an on-device window after PCC, drop irrelevant entries, or redact private data before a less private model.
- **`@SessionProperty(\.history)`**: a **stateful, lossy** edit, shared by all profiles. Used for permanent trimming or summarizing.
- **Custom session properties** (`@SessionPropertyEntry` in an extension on `SessionPropertyValues`): mutable state with an initial value, readable and writable from any profile or tool. Apple's example stores a running summary that is injected into instructions after older entries are dropped.
- **Lifecycle modifiers** `onResponse` / `onToolCall` run imperative code at those boundaries: updating UI, switching modes, trimming history.
- Utilities package modifiers: `.rollingWindow(size: .entries(n))`, `.droppingCompletedToolCalls()`.

### Orchestration patterns (Apple's names)
| Pattern | Mechanism | Transcript | Who answers |
|---|---|---|---|
| **Baton-pass** (collaboration) | a state variable picks the profile; each profile has a tool that flips it; `.onToolCall` reacts | **shared** by all profiles | the profile that **receives** the baton |
| **Phone-a-friend** (consultation) | a tool spawns a **short-lived child session** with its own profile, prompts it, returns the answer as tool output | **isolated** per session | always the **parent** |
| **Skills** (utilities package) | `Skills(activations:) { Skill(name:description:prompt:) }` inside `DynamicInstructions`; a skill's prompt loads into context only when activated | — | — |

### Tool calling mode
- `.allowed` (default): the model may call tools or answer directly.
- `.disallowed`: no tool calls (e.g. the user is in a part of the app where tools are irrelevant).
- `.required`: only tool calls — effectively a loop, **which needs an exit**. Apple shows two: condition the mode on state flipped in `.onToolCall`, or a "final answer" tool that **throws** (throwing aborts the loop).
- Set via the profile modifier or `GenerationOptions(toolCallingMode:)`.

### Errors and transcript mutation
- `transcriptErrorHandlingPolicy`: `.revertTranscript` (default: a thrown tool error or a cancelled response rolls the transcript back) or `.preserveTranscript` (kept as-is; the app repairs it).
- `session.transcript` is now **settable**, but only while `isResponding == false`. Mutating during a response is a programmer error.

### Performance and accuracy of rewriting history
- **KV cache:** appending to the transcript preserves it and keeps time-to-first-token low. Removing entries, changing tools or changing instructions typically **invalidates** it and adds latency. Caching behaviour differs per model; the upgraded Foundation Models Instrument shows invalidations.
- **Model confusion:** rewriting history can mislead the model (Apple's example: titles generated before a title tool existed make the model keep generating them without the tool). The Evaluations framework quantifies the effect of context-engineering changes.

## 10. Vision input (OS 27)

- `Attachment(image)` mixes with text in the `respond { … }` prompt builder. Sources: `UIImage`, `NSImage`, `CGImage`, Core Image types, `CVPixelBuffer`, file URLs.
- Any size or aspect ratio works, with no cropping or padding. **Bigger images cost more tokens and more latency.**

---

## 11. Performance

- **Prewarm:** `session.prewarm()` (⚠️ name from narration) loads the model before a request. The OS may unload the model when it is idle or needed elsewhere, so the first `respond` otherwise includes load time. Apple's guidance: prewarm when the user signals intent (opening a detail screen, starting to type) and the app is idle.
- **Input-token reducers:** short instructions; `includeSchemaInPrompt: false` when safe; short tool names and descriptions; downscaled images.
- **Streaming** hides latency for anything longer than a glance.
- **Session owners created lazily** (e.g. in SwiftUI `.task {}` rather than at view init) are not rebuilt for off-screen views.
- **Profiling:** Instruments' **Foundation Models template** has tracks for asset loading, inference and tool calling, plus input token counts. Simulator timing on Apple Silicon differs from older iPhones.

---

## 12. Prompting & safety — Apple's guidance

- **Xcode `#Playground`** (`import Playgrounds`) runs live in the canvas, like Previews, and can use the app's own types, so one prompt can be run over real sample data.
- Specific prompts give specific output; vague prompts give generic output.
- With guided generation, prompts describe behaviour, not format.
- `@Guide` descriptions are per-field prompts.
- Untrusted input belongs in prompts, not instructions. Guardrail errors are a normal outcome to handle.
- The Evaluations framework measures quality statistically, because output varies from run to run.
- More detail: "Prompt design & safety" (WWDC25).

---

## 13. Developer tooling

| Tool | What it does |
|---|---|
| Xcode `#Playground` | live prompt iteration against app types |
| Scheme → Foundation Models Availability | simulates unavailable states |
| Instruments → Foundation Models | latency breakdown, token counts, effect of prewarm |
| Evaluations framework (27) | statistical quality measurement of AI features |
| `fm` CLI (macOS 27) | `fm chat` for trying prompts against on-device or PCC; scriptable (summarize, extract, name files from images) |
| Python SDK (27) `apple_fm_sdk` | same on-device model from Python: availability, structured responses |
| Feedback Assistant + `LanguageModelFeedbackAttachment` (Encodable) | reports model quality issues to Apple → `code/MeetTheFoundationModelsFramework.swift, code/DeepDiveIntoFoundationModels.swift` |
| Adapter training toolkit | custom adapters; they need **retraining with each model update** |

---

## 14. Open questions

- PCC: the entitlement process, exact daily quotas and the error when exceeded, offline behaviour, latency.
- `reasoningLevel` cases beyond `.light` and `.deep`, and how much latency each adds.
- Whether `ToolOutput` is deprecated in OS 27 in favour of `some PromptRepresentable`.
- Exact `prewarm()` signature.
- The skill API in the utilities package: what it loads and how.
- The Evaluations framework API.
- Not yet ingested: "Building with Private Cloud Compute", "LLM search using Core Spotlight", "What's new in image understanding", "Prompt design & safety", the Evaluations framework sessions, "debugging and profiling".
