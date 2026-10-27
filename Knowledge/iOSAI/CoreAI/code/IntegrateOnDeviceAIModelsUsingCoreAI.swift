// Integrate on-device AI models into your app using Core AI
// WWDC26 session 326 · https://developer.apple.com/videos/play/wwdc2026/326/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [11:01] Load and run SAM3 image segmentation

import CoreAIImageSegmenter

// Load
let segmenter = try await ImageSegmenter(resourcesAt: sam3ModelURL)

// Use
let response = try await segmenter.segment(image: inputImage, prompt: "flower")
let mask = response.segments.first?.mask

// MARK: - [11:28] Load a language model and create a session

import FoundationModels
import CoreAILanguageModels

// Create model instance
let model = try await CoreAILanguageModel(resourcesAt: qwen3ModelURL)

// Create session using the model
let session = LanguageModelSession(model: model)

// Generate response
let response = try await session.respond(to: "...")

// MARK: - [12:29] Generate structured output with @Generable

import FoundationModels
import CoreAILanguageModels

@Generable
struct VocabCard {
    let chineseWord: String
    let englishMeaning: String
    let exampleSentence: String
}

let model = try await CoreAILanguageModel(resourcesAt: modelURL)
let session = LanguageModelSession(model: model)
let response = try await session.respond(
    to: "Create a vocab card for flower",
    generating: VocabCard.self
)
let card: VocabCard = response.content

// MARK: - [17:22] Compile a Core AI model ahead of time

$ xcrun coreai-build compile MyModel.aimodel --platform iOS
