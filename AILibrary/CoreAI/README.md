# Core AI

Reference notes on Apple's Core AI, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data.

API names and shapes are confirmed against Apple's published sample code (see `code/`). Items marked ⚠️ are unconfirmed.

**Platforms:** all Apple Silicon — iOS, iPadOS, macOS 27+ (⚠️ visionOS/tvOS/watchOS unconfirmed)
**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title, holding Apple's published snippets with timestamps. A file's presence means that session's transcript and code are ingested.
**Sources:** WWDC26 324 "Meet Core AI" · WWDC26 325 "Dive into Core AI model authoring and optimization" · WWDC26 326 "Integrate on-device AI models into your app using Core AI"

---

## 1. What it is

Core AI is Apple's on-device inference stack for **your own models**: the successor to Core ML, and the same engine that runs on-device Apple Intelligence. It covers the whole model lifecycle: conversion from PyTorch, optimization/compression, ahead-of-time compilation, debugging, profiling, and a Swift runtime.

- Runs on **CPU, GPU and Neural Engine** across all Apple Silicon.
- **No server, no per-token cost, no cloud latency**; the user's data never leaves the device.
- Scales from tiny models (speaker diarization) through vision-language models to **70B-parameter LLMs** running locally.
- Python side reuses the PyTorch workflow; Core ML Tools users will find it familiar.

### Relationship to Foundation Models
Core AI is the engine; Foundation Models is the LLM-oriented API on top. `CoreAILanguageModel` (from the `coreai-models` Swift package) conforms to the `LanguageModel` protocol, so a custom LLM plugs into `LanguageModelSession` with the same `respond`, streaming and `@Generable` support. See `../FoundationModels/README.md` §3.

---

## 2. Capability catalog

| Capability | What it gives you | Typical uses | Where |
|---|---|---|---|
| **Swift runtime** (`CoreAI` framework) | `AIModel`, `InferenceFunction`, `NDArray`; load `.aimodel`, run inference | any custom model in-app | OS 27 |
| **Stateful inference** (`states:`) | tensors read and updated in place across calls (KV caches) | transformers in decode loops, recurrent models | OS 27 |
| **Multi-function models** | one `.aimodel` with several entry points | run pipeline stages at different cadences (encode once, detect many) | OS 27 |
| **Model specialization + cache** (`AIModelCache`, `AIModel.specialize`) | control when the device-specific compile happens | keeping first-run waits out of interactive flows | OS 27 |
| **Ahead-of-time compilation** (`coreai-build`) | pre-compiled per-architecture assets | much faster first load | toolchain |
| `coreai-torch` (pip) | PyTorch `torch.export` → `.aimodel`; dynamic shapes, states, multi-function, custom kernels | converting any PyTorch model | Python |
| `coreai-opt` | config-driven compression: int4/int8/FP4/FP8, palettization, calibration or QAT | shrinking models for iPhone | Python |
| **Custom Metal 4 kernels** (`TorchMetalKernel`) | your MSL embedded in the asset, with a PyTorch reference | fused ops, cutting-edge layers | Python + Metal |
| **Core AI Debugger** (standalone app) | graph view, per-op tensor values on real hardware, comparison against PyTorch intermediates (sync points, PSNR) | diagnosing quantization or numeric errors | macOS app |
| **Core AI Instrument** + Xcode debug gauge | inference latency, load/specialization events, streaming activity | performance work | Xcode |
| **`coreai-models` repo** | ready models (LLMs, SAM 3, Qwen…), export recipes, Swift runtime libraries, agent skills | not converting from scratch | GitHub |
| Swift libraries: `CoreAILanguageModels`, `CoreAIImageSegmenter` | one-line model loading with tokenizer/pre/post-processing abstracted | LLM via Foundation Models, text-prompted segmentation | Swift package |
| **Core AI agent skills** | skills for coding assistants with Apple's best practices for authoring/conversion/optimization | letting an AI assistant do Core AI work | repo |
| Low-level inference APIs | optimal memory layout query, pre-allocated outputs, async value pipelining | tight inference loops, compute pipelines | OS 27 |

---

## 3. Swift runtime

→ `code/MeetCoreAI.swift`

### Core types
- **`AIModel`**: `try await AIModel(contentsOf: url)` loads a `.aimodel`. Used to inspect and load inference functions.
- **`InferenceFunction`**: one runnable compute graph. `try model.loadFunction(named: "main")!`. Most models have one `main`; multi-function models expose several.
- **`NDArray`**: multi-dimensional input/output data. `NDArray(shape: [n, d], scalarType: .float32)`.
  - `NDArray.MutableView<T>` / `NDArray.View<T>`: **non-escapable** types giving safe, zero-copy access to storage (`mutableView()`, `view()`).
- **`run`**: `try await function.run(inputs: ["name": ndarray])` returns outputs keyed by name; `outputs.remove("logits")?.ndArray`.
- Apple positions the API as **progressively disclosing**: a simple top layer, with lower-level layers for performance-critical work.
- Typical lifecycle: `AIModel` and `InferenceFunction` are created once when the feature is prepared (e.g. app init); `NDArray`s per inference.

### States (KV cache pattern)
- A **state** is an input that is both read and updated **in place** during inference.
- Swift side: keep state `NDArray`s as stored properties; build `InferenceFunction.MutableViews()`, `insert(&cache, for: "keyCache")`, pass as `states:` to `run`.
- Python side: `register_buffer` tensors in the `nn.Module`, read/write them in `forward`, and name them in `state_names=` at conversion.
- Effect in Apple's demo: a transformer whose latency grew quadratically with sequence length became steady, since only the newest step is fed each call.

### Xcode integration
- Opening a `.aimodel` in Xcode shows size, operation distribution, metadata, target OS, and a **Functions tab** with each function's exact signature. `?` in a shape marks a dynamic dimension.
- A **debug gauge** shows streaming Core AI activity while running; the **Core AI Instrument** gives inference intervals and load/specialization events.

---

## 4. Specialization, caching, ahead-of-time compilation

→ `code/MeetCoreAI.swift`

- A shipped `.aimodel` is a **source representation** runnable on any Apple device. Before it runs it must be **specialized** for the specific device and OS: (1) compilation (segment, plan, optimize compute, the expensive part) and (2) generation of executable artifacts tied to that device + OS version.
- Specialization happens on first load, is **cached**, and later loads are fast. For large models the first time is long; Apple's guidance keeps it out of user-interactive flows.
- **`AIModelCache.default`**: `try cache.model(for: url, options: .default)` returns `nil` when not yet specialized, which gates features or shows a "preparing" message. The cache supports deleting entries, persistence policy, and **sharing between apps in an app group**.
- **`try await AIModel.specialize(contentsOf: url)`** requests specialization explicitly (e.g. after an asset download or on opt-in). `SpecializationOptions` configures optimization for inference.
- **Ahead-of-time compilation**: `xcrun coreai-build compile Model.aimodel --platform iOS` produces compiled models per device architecture. They still specialize on the device, but with much less work. Apple's pattern: one **Background Asset** per compiled model, with the app picking by device architecture.
- Articles Apple references: "Managing model specialization and caching", "Compiling Core AI models ahead of time".

### Deployment pattern from session 326
- Models can add **>1 GB** to an app. Apple's example ships them as **Apple-Hosted Background Assets**, downloaded only when the user opts into the feature, from a first-run screen that also hosts specialization.
- Feature discoverable but not required; a non-AI app path stays intact.

---

## 5. Python: conversion

→ `code/MeetCoreAI.swift, code/DiveIntoCoreAIModelAuthoring.py`

- `pip install coreai-torch` installs `coreai` and `coreai-torch`.
- Pipeline: `torch.export.export(model, args, dynamic_shapes=…)` → `exported.run_decompositions(coreai_torch.get_decomp_table())` (preserves high-level semantics Core AI supports, e.g. attention) → `coreai_torch.TorchConverter().add_exported_program(exported, input_names=, output_names=, state_names=)` → `.to_coreai()` → `program.optimize()` → `program.save_asset("x.aimodel")`.
- **Dynamic shapes** via `torch.export.Dim("seq_len", min=, max=)`; the converted function shows `?` for that dimension.
- **Multiple functions**: one `TorchConverter`, several `add_exported_program` calls, each with its own entry-point name → one asset with several callable functions.
- **Python runtime** (`coreai.runtime`): `await AIModel.load("x.aimodel")`, `load_function("main")`, `await function({"name": NDArray(numpy_array)})`, `result["logits"].numpy()`. Used to **verify numerics** against the PyTorch model (Apple's check: max abs diff < 0.01).
- **Custom Metal kernels**: `TorchMetalKernel(name:, input_names:, result_names:, src: MSL, torch_defn: python_reference, metal_params:, template_dtypes:)`; called in `forward` with `threads_per_grid_size`, `threads_per_thread_group`, `result_shapes` (so output shapes derive from input shapes under dynamic shapes); `converter.register_custom_kernels([...])`. The MSL ships inside the asset. Deep dive: "Optimize custom machine learning operations with Metal tensors".

---

## 6. Python: optimization (`coreai-opt`)

→ `code/DiveIntoCoreAIModelAuthoring.py`

- Config-driven compression: describe what to compress and what to leave alone; different schemes per platform (e.g. macOS vs iOS).
- Weight formats: **int4, int8, FP4, FP8** with flexible granularity; **palettization** (lookup-table based, e.g. 4-bit with per-channel scales), noted by Apple as power-efficient on iOS.
- Quantization APIs: with a small calibration set, or **quantization-aware training** on larger data.
- Presets: `presets.w4` = 4-bit per-channel symmetric quantization in one line. `ExecutionMode.EAGER` for weight compression; `GRAPH` mode for activations.
- Workflow: `Quantizer(model, config)` / `KMeansPalettizer(model, config)` → prepare with example inputs → finalize → same export pipeline.
- Helper for casting the program to **FP16**.
- Apple's SAM 3 case: FP32 asset >3 GB → 4-bit ~430 MB, but uniform compression broke one detection. The detector (4% of parameters) was compression-sensitive; excluding it restored baseline quality at a fraction of the size.

### Model re-authoring (advanced)
- Rewriting the PyTorch source for a target rather than converting as-is: fused ops (Core AI ships fast kernels for e.g. scaled-dot-product attention), **predefined PyTorch patterns** that Core AI maps to optimized runtime implementations (e.g. in-place KV-cache updates), and for iOS: **static shapes, channels-first layouts, convolutional projections** instead of `Linear`, to hit native hardware primitives.
- Splitting a model into independent functions lets each run at its own cadence and be compressed separately. Apple's SAM 3 split (image_encode / text_encode / detect) made a prompt-only re-run **76% faster**.
- Apple notes re-authored models need module-level and model-level tests. Examples live in `coreai-models`.

---

## 7. Core AI Debugger

- Standalone macOS app. Open a `.aimodel`, **Inspect**.
- **Navigator**: operations grouped by their **PyTorch module**. **Structure viewer**: graph of connectivity, execution order, data dependencies. **Source viewer**: the originating Python line. **Inspector**: op description, inputs/outputs.
- **Run on device** (choose target + inputs in a scheme) → the graph updates to the specialized model as it runs on that hardware, and every op's output tensor is viewable, including image previews.
- **Comparison sessions**: compare two configurations (target, compute unit) or against a **reference run** saved from PyTorch with the **save-intermediates API**. The debugger finds **sync points** (op pairs expected to match) and scores each with a similarity metric (**PSNR** default, others selectable); green/yellow/red nodes, sortable by similarity.
- Apple's use: locating which module's quantization caused a lost detection in minutes.

---

## 8. `coreai-models` repository

→ `code/IntegrateOnDeviceAIModelsUsingCoreAI.swift`

- `models/`: catalog of popular models (LLM families, SAM 3, Qwen…) each with an **export recipe** ("a single command away") and optional platform-specific variants.
- `python/`: reusable export primitives and utilities, reusable components (e.g. KV-cache patterns) and best practices.
- **Swift package**: runtime libraries with pre/post-processing built in:
  - `CoreAILanguageModels` → `CoreAILanguageModel(resourcesAt:)`: asset loading, engine, tokenizer in one line; passes to `LanguageModelSession(model:)`. Custom **token sampling strategies** are supported.
  - `CoreAIImageSegmenter` → `ImageSegmenter(resourcesAt:)`, `segment(image:prompt:)` → `response.segments.first?.mask`.
- **Agent skills** for coding assistants (authoring, optimization, conversion). Apple states most code in session 325 was co-developed with an agent using them.

---

## 9. Model selection and sizing (Apple's worked example, session 326)

- Requirements framed as **content**, **languages**, **device constraints** (storage + memory on iPhone).
- Decomposed into **two task-specific models under 1B parameters each** (SAM 3 for segmentation, Qwen3 0.6B for multilingual reasoning with structured output) rather than one large model: better quality per task, smaller individual sizes, independently upgradable.
- Same code on macOS with a larger variant (Qwen3 8B): longer context, richer prompts, visible reasoning, batch processing; different model, same `LanguageModelSession` API.
- Model discovery via Hugging Face, GitHub, and the `coreai-models` catalog.

---

## 10. Performance and low-level APIs

- Transformers without KV caching show latency growing with sequence length; states fix it (§3).
- Low-level inference APIs: query the **optimal memory layout** for `NDArray` arguments and allocate accordingly (avoids layout conversion at inference), **pre-allocate outputs** for the framework to write into, and **asynchronous values** to pipeline multiple inference functions. ⚠️ Exact API names not shown.
- Profiling: Core AI Instrument (inference intervals, model load, specialization sub-events).

---

## 11. Open questions

- Exact Swift API names for the low-level layout/pre-allocation/async-value APIs, `SpecializationOptions` fields, `AIModelCache` policies.
- Which `coreai-models` Swift products exist beyond `CoreAILanguageModels` / `CoreAILM` and `CoreAIImageSegmenter` / `CoreAISegmentation` (both names appear across slides).
- `coreai-build` options and output layout; how the app detects device architecture for asset selection.
- Supported platforms beyond iOS/macOS; minimum hardware.
- `.aimodel` vs Core ML `.mlpackage`: migration path and coexistence.
- Not yet ingested: "Optimize custom machine learning operations with Metal tensors", "Discover Apple-Hosted Background Assets" (WWDC25), the two developer.apple.com articles on specialization/caching and AOT compilation.
