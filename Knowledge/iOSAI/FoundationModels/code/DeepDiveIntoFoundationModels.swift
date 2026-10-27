// Deep dive into the Foundation Models framework
// WWDC25 session 301 · https://developer.apple.com/videos/play/wwdc2025/301/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [1:05] Prompting a session

import FoundationModels

func respond(userInput: String) async throws -> String {
  let session = LanguageModelSession(instructions: """
    You are a friendly barista in a world full of pixels.
    Respond to the player’s question.
    """
  )
  let response = try await session.respond(to: userInput)
  return response.content
}

// MARK: - [3:37] Handle context size errors

var session = LanguageModelSession()

do {
  let answer = try await session.respond(to: prompt)
  print(answer.content)
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
  // New session, without any history from the previous session.
  session = LanguageModelSession()
}

// MARK: - [3:55] Handling context size errors with a new session

var session = LanguageModelSession()

do {
  let answer = try await session.respond(to: prompt)
  print(answer.content)
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
  // New session, with some history from the previous session.
  session = newSession(previousSession: session)
}

private func newSession(previousSession: LanguageModelSession) -> LanguageModelSession {
  let allEntries = previousSession.transcript.entries
  var condensedEntries = [Transcript.Entry]()
  if let firstEntry = allEntries.first {
    condensedEntries.append(firstEntry)
    if allEntries.count > 1, let lastEntry = allEntries.last {
      condensedEntries.append(lastEntry)
    }
  }
  let condensedTranscript = Transcript(entries: condensedEntries)
  // Note: transcript includes instructions.
  return LanguageModelSession(transcript: condensedTranscript)
}

// MARK: - [6:14] Sampling

// Deterministic output
let response = try await session.respond(
  to: prompt,
  options: GenerationOptions(sampling: .greedy)
)
                
// Low-variance output
let response = try await session.respond(
  to: prompt,
  options: GenerationOptions(temperature: 0.5)
)
                
// High-variance output
let response = try await session.respond(
  to: prompt,
  options: GenerationOptions(temperature: 2.0)
)

// MARK: - [7:06] Handling languages

var session = LanguageModelSession()

do {
  let answer = try await session.respond(to: userInput)
  print(answer.content)
} catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
  // Unsupported language in prompt.
}

let supportedLanguages = SystemLanguageModel.default.supportedLanguages
guard supportedLanguages.contains(Locale.current.language) else {
  // Show message
  return
}

// MARK: - [8:14] Generable

@Generable
struct NPC {
  let name: String
  let coffeeOrder: String
}

func makeNPC() async throws -> NPC {
  let session = LanguageModelSession(instructions: ...)
  let response = try await session.respond(generating: NPC.self) {
    "Generate a character that orders a coffee."
  }
  return response.content
}

// MARK: - [9:22] NPC

@Generable
struct NPC {
  let name: String
  let coffeeOrder: String
}

// MARK: - [10:49] Generable with enum

@Generable
struct NPC {
  let name: String
  let encounter: Encounter

  @Generable
  enum Encounter {
    case orderCoffee(String)
    case wantToTalkToManager(complaint: String)
  }
}

// MARK: - [11:20] Generable with guides

@Generable
struct NPC {
  @Guide(description: "A full name")
  let name: String
  @Guide(.range(1...10))
  let level: Int
  @Guide(.count(3))
  let attributes: [Attribute]
  let encounter: Encounter

  @Generable
  enum Attribute {
    case sassy
    case tired
    case hungry
  }
  @Generable
  enum Encounter {
    case orderCoffee(String)
    case wantToTalkToManager(complaint: String)
  }
}

// MARK: - [13:40] Regex guide

@Generable
struct NPC {
  @Guide(Regex {
    Capture {
      ChoiceOf {
        "Mr"
        "Mrs"
      }
    }
    ". "
    OneOrMore(.word)
  })
  let name: String
}

session.respond(to: "Generate a fun NPC", generating: NPC.self)
// > {name: "Mrs. Brewster"}

// MARK: - [14:50] Generable riddle

@Generable
struct Riddle {
  let question: String
  let answers: [Answer]

  @Generable
  struct Answer {
    let text: String
    let isCorrect: Bool
  }
}

// MARK: - [15:10] Dynamic schema

struct LevelObjectCreator {
  var properties: [DynamicGenerationSchema.Property] = []

  mutating func addStringProperty(name: String) {
    let property = DynamicGenerationSchema.Property(
      name: name,
      schema: DynamicGenerationSchema(type: String.self)
    )
    properties.append(property)
  }

  mutating func addArrayProperty(name: String, customType: String) {
    let property = DynamicGenerationSchema.Property(
      name: name,
      schema: DynamicGenerationSchema(
        arrayOf: DynamicGenerationSchema(referenceTo: customType)
      )
    )
    properties.append(property)
  }
  
  var root: DynamicGenerationSchema {
    DynamicGenerationSchema(
      name: name,
      properties: properties
    )
  }
}

var riddleBuilder = LevelObjectCreator(name: "Riddle")
riddleBuilder.addStringProperty(name: "question")
riddleBuilder.addArrayProperty(name: "answers", customType: "Answer")

var answerBuilder = LevelObjectCreator(name: "Answer")
answerBuilder.addStringProperty(name: "text")
answerBuilder.addBoolProperty(name: "isCorrect")

let riddleDynamicSchema = riddleBuilder.root
let answerDynamicSchema = answerBuilder.root

let schema = try GenerationSchema(
  root: riddleDynamicSchema,
  dependencies: [answerDynamicSchema]
)

let session = LanguageModelSession()
let response = try await session.respond(
  to: "Generate a fun riddle about coffee",
  schema: schema
)
let generatedContent = response.content
let question = try generatedContent.value(String.self, forProperty: "question")
let answers = try generatedContent.value([GeneratedContent].self, forProperty: "answers")

// MARK: - [18:47] FindContactTool

import FoundationModels
import Contacts

struct FindContactTool: Tool {
  let name = "findContact"
  let description = "Finds a contact from a specified age generation."
    
  @Generable
  struct Arguments {
    let generation: Generation
        
    @Generable
    enum Generation {
      case babyBoomers
      case genX
      case millennial
      case genZ            
    }
  }
  
  func call(arguments: Arguments) async throws -> ToolOutput {
    let store = CNContactStore()
        
    let keysToFetch = [CNContactGivenNameKey, CNContactBirthdayKey] as [CNKeyDescriptor]
    let request = CNContactFetchRequest(keysToFetch: keysToFetch)

    var contacts: [CNContact] = []
    try store.enumerateContacts(with: request) { contact, stop in
      if let year = contact.birthday?.year {
        if arguments.generation.yearRange.contains(year) {
          contacts.append(contact)
        }
      }
    }
    guard let pickedContact = contacts.randomElement() else {
      return ToolOutput("Could not find a contact.")
    }
    return ToolOutput(pickedContact.givenName)
  }
}

// MARK: - [20:26] Call FindContactTool

import FoundationModels

let session = LanguageModelSession(
  tools: [FindContactTool()],
  instructions: "Generate fun NPCs"
)

// MARK: - [21:55] FindContactTool with state

import FoundationModels
import Contacts

class FindContactTool: Tool {
  let name = "findContact"
  let description = "Finds a contact from a specified age generation."
   
  var pickedContacts = Set<String>()
    
  ...

  func call(arguments: Arguments) async throws -> ToolOutput {
    contacts.removeAll(where: { pickedContacts.contains($0.givenName) })
    guard let pickedContact = contacts.randomElement() else {
      return ToolOutput("Could not find a contact.")
    }
    return ToolOutput(pickedContact.givenName)
  }
}

// MARK: - [22:27] GetContactEventTool

import FoundationModels
import EventKit

struct GetContactEventTool: Tool {
  let name = "getContactEvent"
  let description = "Get an event with a contact."

  let contactName: String
    
  @Generable
  struct Arguments {
    let day: Int
    let month: Int
    let year: Int
  }
    
  func call(arguments: Arguments) async throws -> ToolOutput { ... }
}
