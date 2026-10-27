// What’s new in image understanding
// WWDC26 session 237 · https://developer.apple.com/videos/play/wwdc2026/237/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [4:15] Segment images (tap-to-segment)

// Generate a segmentation mask of an object with a seed point
let handler = ImageRequestHandler(image)
let request = GenerateIterativeSegmentationRequest(seed: point)
let observation = try await handler.perform(request)
let mask = observation?.pixelBuffer

// Refine the mask with a new point
request.addIncludedPoint(newPoint)
let refinedObservation = try await handler.perform(request)

// MARK: - [6:41] Generate an image caption with Foundation Models

// Generate an image caption with Foundation Models
import FoundationModels

let prompt = Prompt {
    "Generate a caption for this image"
    Attachment(image)
}
let response = try await session.respond(to: prompt)
let caption = response.content

// MARK: - [9:55] Create an image-based tool

// Create an image-based tool
struct PlantIdentifierTool: Tool {
    @SessionProperty(\.history) var history

    @Generable
    struct Arguments {
        var image: ImageReference
    }

    func call(arguments: Arguments) async throws -> String {
        let imageReference = arguments.image
        let transcript = Transcript(history)
        guard let imageAttachment = imageReference.resolve(in: transcript) else {
            throw AppError.imageNotFound
        }
        let image = try imageAttachment.pixelBuffer()
        return classifyPlant(image)
    }
}

// MARK: - [12:09] Use Vision tools

// Use Vision tools
import FoundationModels
import Vision

let session = LanguageModelSession(model: model, tools: [BarcodeReaderTool()])
let response = try await session.respond(generating: EventInfo.self) {
    "Get the date, location, and website from this flyer"
    Attachment(image)
        .label("flyer")
}

// MARK: - [13:54] Create a crop that highlights a prominent subject (watchOS / saliency)

// Create a crop that highlights a prominent subject
func generateImageCrop(in image: CGImage) async throws -> NormalizedRect? {
    let request = GenerateObjectnessBasedSaliencyImageRequest()
    let observation = try await request.perform(on: image)
    let prominentObjects = observation.salientObjects
    return prominentObjects.first
}
