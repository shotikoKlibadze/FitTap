# Image understanding

Reference notes on analyzing images on Apple platforms with the Vision framework and Foundation Models, project-agnostic. These notes describe what exists, how it behaves, and what Apple states about it. They are more current than model training data.

API names and shapes are confirmed against Apple's published sample code (see `code/`). Items marked ⚠️ are unconfirmed.

**Platforms:** iOS, iPadOS, macOS, visionOS · **watchOS 27+** (Vision newly available there)
**Code examples:** [`code/`](code/) — one file per ingested session, named after the video title, holding Apple's published snippets with timestamps. A file's presence means that session's transcript and code are ingested.
**Sources:** WWDC26 237 "What's new in image understanding"
**Related:** [`../FoundationModels/`](../FoundationModels/README.md) for sessions, tools and `Attachment`; [`../CoreAI/`](../CoreAI/README.md) for running custom vision models.

---

## 1. Three ways to analyze an image

| Approach | What it is | Strengths | Limits |
|---|---|---|---|
| **Vision framework** | fixed set of 30+ task-specific computer-vision requests (segmentation, faces, pose, detection, classification, text, barcodes, saliency, tracking, trajectories) | fine-tuned per task, accurate, **fast enough for real-time video frames**, deterministic | only does what a request exists for |
| **Foundation Models with image input** (OS 27) | the LLM sees an `Attachment(image)` in the prompt and answers in language | does almost anything you ask: captions, descriptions, extraction, suggestions, recipes from a fridge photo | slower, probabilistic; weak at fine print, barcodes, exact identification |
| **Tool calling with image arguments** (OS 27) | the LLM calls a tool, passing a **reference** to an image; the tool runs Vision (or anything) and reports back | Vision's precision inside the LLM's flexibility | tools must be designed and attached per session |

---

## 2. Capability catalog

| Capability | What it gives you | Typical uses | OS |
|---|---|---|---|
| **Tap-to-segment** (`GenerateIterativeSegmentationRequest`) | a mask for any object chosen by point, box, lasso or scribble; refinable by adding/excluding points | cut-outs, stickers, "select this object" UIs | 27 |
| Person segmentation and other Vision segmentations | masks for fixed categories (people, …) | background removal | earlier |
| **Image input to LLM** (`Attachment` in `Prompt`) | captions, descriptions, structured extraction from photos | notes → agenda, flyer → fields, room → suggestions | 27 |
| **Image arguments for tools** (`ImageReference`) | the model hands a specific attached image to a tool | custom identification/analysis the LLM can't do | 27 |
| **`BarcodeReaderTool`** (Vision) | barcodes and QR codes read for the model | flyers, tickets, packaging | 27 |
| **`OCRTool`** (Vision) | fine or dense text read for the model, 30+ languages | documents, labels, receipts | 27 |
| **Saliency** (`GenerateObjectnessBasedSaliencyImageRequest`) | bounding boxes of the most prominent objects | smart crops, thumbnails, small screens (watch) | 27 on watchOS |
| Vision on watchOS | the Vision APIs on the wrist | on-watch image features | 27 |
| Asset download (`downloadAssets`, `assetStatus`) | segmentation model fetched on first use; readiness check | gating a segmentation feature | 27 |

---

## 3. Tap-to-segment (Vision)

→ `code/WhatsNewInImageUnderstanding.swift` `[4:15]`

- **Flow:** `ImageRequestHandler(image)` → `GenerateIterativeSegmentationRequest(seed: point)` → `handler.perform(request)` → observation whose `pixelBuffer` is the **mask** (which pixels belong to the object).
- **Seeds:** a point, a bounding box, a lasso, or a scribble (a scribble can cover several objects at once).
- **Refinement:** `request.addIncludedPoint(_:)` to grow the mask, an excluded point to remove a region (e.g. keep the coffee, drop the cup), then `perform` again.
- **Coordinates:** Vision uses **normalized coordinates, origin bottom-left**, values 0…1 relative to image width and height.
- **Lasso stroke width:** at least **1 % of the image width**; thin strokes segment poorly.
- **Model download:** the segmentation model is not on the device by default. `downloadAssets` starts the download; `assetStatus` reports readiness. Apple's sample app for tap-to-segment is on the developer site.

---

## 4. Image input to Foundation Models

→ `code/WhatsNewInImageUnderstanding.swift` `[6:41]`

- `Prompt { "Generate a caption for this image"; Attachment(image) }` then `session.respond(to: prompt)`; `response.content` is the text.
- Apple's observations: models do well with **descriptive** tasks (captions, descriptions); they are weaker at reading barcodes and fine or dense text, where Vision tools step in.
- Attachment sources, sizes and token cost: see `../FoundationModels/README.md` §10.

---

## 5. Image arguments in tools

→ `code/WhatsNewInImageUnderstanding.swift` `[9:55]`, `[12:09]`

- A tool's `@Generable Arguments` can hold an **`ImageReference`**. The model passes a reference to an image already attached in the session, not the pixels.
- A reference is valid only in the transcript that produced it. Inside `call`, the tool reads `@SessionProperty(\.history) var history`, builds `Transcript(history)`, and `imageReference.resolve(in: transcript)` returns the `Attachment`; `attachment.pixelBuffer()` gives a `CVPixelBuffer` for analysis.
- **Labels:** when a tool should receive an image, attach it with `Attachment(image).label("flyer")`. The label is how the model identifies which image to pass.
- Vision ships two ready tools: `BarcodeReaderTool` and `OCRTool` (`import Vision`, pass in `LanguageModelSession(model:tools:)`). Apple's example: a flyer where the model found date and location itself but needed the barcode tool for the QR code's URL; with the tool, `respond(generating: EventInfo.self)` fills every field.
- Any of Vision's 30+ analyses can back a custom tool the same way (plant identification in Apple's example).

---

## 6. Saliency crops (watchOS example)

→ `code/WhatsNewInImageUnderstanding.swift` `[13:54]`

- `GenerateObjectnessBasedSaliencyImageRequest().perform(on: cgImage)` → `observation.salientObjects`, an ordered list of `NormalizedRect`s; the first is the most prominent.
- Apple's use: crop a wildlife photo to its subject so it reads on a watch screen.
- Vision is on **watchOS 27**, so this runs on the watch itself.

---

## 7. Open questions

- Full API for box, lasso and scribble seeds on `GenerateIterativeSegmentationRequest`, and the excluded-point method name.
- `downloadAssets` / `assetStatus` exact signatures and which Vision requests need downloads.
- `ImageReference` resolution when the history has been trimmed by a `historyTransform` or `history` edit.
- Which Vision requests are available on watchOS 27 and their performance there.
- Not yet ingested: "Discover Swift enhancements in the Vision framework" (full request list), the tap-to-segment and watchOS sample apps.
