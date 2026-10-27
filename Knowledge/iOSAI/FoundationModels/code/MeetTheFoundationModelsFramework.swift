// Meet the Foundation Models framework
// WWDC25 session 286 · https://developer.apple.com/videos/play/wwdc2025/286/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [2:28] Playground - Trip to Japan

import FoundationModels
import Playgrounds

#Playground {
    let session = LanguageModelSession()
    let response = try await session.respond(to: "What's a good name for a trip to Japan? Respond only with a title")
}

// MARK: - [2:43] Playground - Loop over landmarks

import FoundationModels
import Playgrounds

#Playground {
    let session = LanguageModelSession()
    for landmark in ModelData.shared.landmarks {
        let response = try await session.respond(to: "What's a good name for a trip to \(landmark.name)? Respond only with a title")
    }
}

// MARK: - [5:32] Creating a Generable struct

// Creating a Generable struct

@Generable
struct SearchSuggestions {
    @Guide(description: "A list of suggested search terms", .count(4))
    var searchTerms: [String]
}

// MARK: - [5:51] Responding with a Generable type

// Responding with a Generable type

let prompt = """
    Generate a list of suggested search terms for an app about visiting famous landmarks.
    """

let response = try await session.respond(
    to: prompt,
    generating: SearchSuggestions.self
)

print(response.content)

// MARK: - [6:18] Composing Generable types

// Composing Generable types

@Generable struct Itinerary {
    var destination: String
    var days: Int
    var budget: Float
    var rating: Double
    var requiresVisa: Bool
    var activities: [String]
    var emergencyContact: Person
    var relatedItineraries: [Itinerary]
}

// MARK: - [9:20] PartiallyGenerated types

// PartiallyGenerated types

@Generable struct Itinerary {
    var name: String
    var days: [Day]
}

// MARK: - [9:40] Streaming partial generations

// Streaming partial generations

let stream = session.streamResponse(
    to: "Craft a 3-day itinerary to Mt. Fuji.",
    generating: Itinerary.self
)

for try await partial in stream {
    print(partial)
}

// MARK: - [10:05] Streaming itinerary view

struct ItineraryView: View {
    let session: LanguageModelSession
    let dayCount: Int
    let landmarkName: String
  
    @State
    private var itinerary: Itinerary.PartiallyGenerated?
  
    var body: some View {
        //...
        Button("Start") {
            Task {
                do {
                    let prompt = """
                        Generate a \(dayCount) itinerary \
                        to \(landmarkName).
                        """
                  
                    let stream = session.streamResponse(
                        to: prompt,
                        generating: Itinerary.self
                    )
                  
                    for try await partial in stream {
                        self.itinerary = partial
                    }
                } catch {
                    print(error)  
                }
            }
        }
    }
}

// MARK: - [11:00] Property order matters

@Generable struct Itinerary {
  
  @Guide(description: "Plans for each day")
  var days: [DayPlan]
  
  @Guide(description: "A brief summary of plans")
  var summary: String
}

// MARK: - [13:42] Defining a tool

// Defining a tool
import WeatherKit
import CoreLocation
import FoundationModels

struct GetWeatherTool: Tool {
    let name = "getWeather"
    let description = "Retrieve the latest weather information for a city"

    @Generable
    struct Arguments {
        @Guide(description: "The city to fetch the weather for")
        var city: String
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let places = try await CLGeocoder().geocodeAddressString(arguments.city)
        let weather = try await WeatherService.shared.weather(for: places.first!.location!)
        let temperature = weather.currentWeather.temperature.value

        let content = GeneratedContent(properties: ["temperature": temperature])
        let output = ToolOutput(content)

        // Or if your tool’s output is natural language:
        // let output = ToolOutput("\(arguments.city)'s temperature is \(temperature) degrees.")

        return output
    }
}

// MARK: - [15:03] Attaching tools to a session

// Attaching tools to a session

let session = LanguageModelSession(
    tools: [GetWeatherTool()],
    instructions: "Help the user with weather forecasts."
)

let response = try await session.respond(
    to: "What is the temperature in Cupertino?"
)

print(response.content)
// It’s 71˚F in Cupertino!

// MARK: - [16:30] Supplying custom instructions

// Supplying custom instructions

let session = LanguageModelSession(
    instructions: """
        You are a helpful assistant who always \
        responds in rhyme.
        """
)

// MARK: - [17:46] Multi-turn interactions

// Multi-turn interactions

let session = LanguageModelSession()

let firstHaiku = try await session.respond(to: "Write a haiku about fishing")
print(firstHaiku.content)
// Silent waters gleam,
// Casting lines in morning mist—
// Hope in every cast.

let secondHaiku = try await session.respond(to: "Do another one about golf")
print(secondHaiku.content)
// Silent morning dew,
// Caddies guide with gentle words—
// Paths of patience tread.

print(session.transcript) // (Prompt) Write a haiku about fishing
// (Response) Silent waters gleam...
// (Prompt) Do another one about golf
// (Response) Silent morning dew...

// MARK: - [18:22] Gate on isResponding

import SwiftUI
import FoundationModels

struct HaikuView: View {

    @State
    private var session = LanguageModelSession()

    @State
    private var haiku: String?

    var body: some View {
        if let haiku {
            Text(haiku)
        }
        Button("Go!") {
            Task {
                haiku = try await session.respond(
                    to: "Write a haiku about something you haven't yet"
                ).content
            }
        }
        // Gate on `isResponding`
        .disabled(session.isResponding)
    }
}

// MARK: - [18:39] Using a built-in use case

// Using a built-in use case

let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging)
)

// MARK: - [19:19] Content tagging use case - 1

// Content tagging use case

@Generable
struct Result {
    let topics: [String]
}

let session = LanguageModelSession(model: SystemLanguageModel(useCase: .contentTagging))
let response = try await session.respond(to: ..., generating: Result.self)

// MARK: - [19:35] Content tagging use case - 2

// Content tagging use case

@Generable
struct Top3ActionEmotionResult {
    @Guide(.maximumCount(3))
    let actions: [String]
    @Guide(.maximumCount(3))
    let emotions: [String]
}

let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    instructions: "Tag the 3 most important actions and emotions in the given input text."
)
let response = try await session.respond(to: ..., generating: Top3ActionEmotionResult.self)

// MARK: - [19:56] Availability checking

// Availability checking

struct AvailabilityExample: View {
    private let model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            Text("Model is available").foregroundStyle(.green)
        case .unavailable(let reason):
            Text("Model is unavailable").foregroundStyle(.red)
            Text("Reason: \(reason)")
        }
    }
}

// MARK: - [22:13] Encodable feedback attachment data structure

let feedback = LanguageModelFeedbackAttachment(
  input: [
    // ...
  ],
  output: [
    // ...
  ],
  sentiment: .negative,
  issues: [
    LanguageModelFeedbackAttachment.Issue(
      category: .incorrect,
      explanation: "..."
    )
  ],
  desiredOutputExamples: [
    [
      // ...
    ]
  ]
)
let data = try JSONEncoder().encode(feedback)
