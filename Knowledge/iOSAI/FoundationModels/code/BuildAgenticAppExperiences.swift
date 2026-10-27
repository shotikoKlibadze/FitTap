// Build agentic app experiences with the Foundation Models framework
// WWDC26 session 242 · https://developer.apple.com/videos/play/wwdc2026/242/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [5:04] DynamicInstructions

// DynamicInstructions
  
  struct BrainstormFacilitator: DynamicInstructions {
      var orchestrator: CraftOrchestrator
      var body: some DynamicInstructions {
          Instructions {
              "You are a warm and friendly expert crafting brainstorm facilitator."
          }
          // Tools
          GenerateProjectTitle()
          // Conditionally include Origami knowledge
          if orchestrator.techniques.contains(.origami) {
              OrigamiExpert()
          }
      }
  }

// MARK: - [6:41] DynamicProfile

// DynamicProfile

  struct CraftProfile: LanguageModelSession.DynamicProfile {
      var orchestrator: CraftOrchestrator
      var body: some DynamicProfile {
          switch orchestrator.mode {
          case .brainstorming:
              Profile { BrainstormFacilitator(orchestrator: orchestrator) }
                  .model(orchestrator.pccLanguageModel)
                  .temperature(1)
          case .planning:
              Profile { TutorialAuthor(orchestrator: orchestrator) }
                  .model(orchestrator.pccLanguageModel)
                  .reasoningLevel(.deep)
          case .reviewing:
              Profile { CraftCoach() }
                  .model(orchestrator.systemLanguageModel)
          }
      }
  }

// MARK: - [6:43] Initialize your session with your dynamic profile

// Initialize your session with your dynamic profile
  let session = LanguageModelSession(profile: CraftProfile(orchestrator: orchestrator))

// MARK: - [8:33] Transcript management

// Transcript management
  
  struct CraftProfile: LanguageModelSession.DynamicProfile {
      var orchestrator: CraftOrchestrator
      var body: some DynamicProfile {
          switch orchestrator.mode {
          case .reviewing:
              Profile { CraftCoach() }
                  .model(orchestrator.systemLanguageModel)
                  .historyTransform { history in
                      // Update the history for your profile
                      guard let latestResponseIndex = lastResponseEntryIndex(history) else {
                          return history
                      }
                      let filteredHistory = history[0..<latestResponseIndex].filter { entry in
                          isToolCallsOrToolOutput(entry)
                      }
                      return filteredHistory + history[latestResponseIndex...]
                  }
          }
      }
  }

// MARK: - [9:15] Custom modifiers

// Custom modifiers
  
  struct DroppingToolCallsProfileModifier: LanguageModelSession.DynamicProfileModifier {
      func body(content: Content) -> some DynamicProfile {
          content
              .historyTransform { history in
                  guard let latestResponseIndex = lastResponseEntryIndex(history) else {
                      return history
                  }
                  let filteredHistory = history[0..<latestResponseIndex].filter { entry in
                      isToolCallsOrToolOutput(entry)
                  }
                  return filteredHistory + history[latestResponseIndex...]
              }
      }
  }

  extension LanguageModelSession.DynamicProfile {
      func droppingCompletedToolCalls() -> some DynamicProfile {
          self.modifier(DroppingToolCallsProfileModifier())
      }
  }

// MARK: - [9:27] History management modifiers

// History management modifiers

  import FoundationModelsUtilities

  struct CraftProfile: LanguageModelSession.DynamicProfile {
      var orchestrator: CraftOrchestrator
      var body: some DynamicProfile {
          switch orchestrator.mode {
          case .reviewing:
              Profile { CraftCoach() }
                  // Keep the most recent 10 entries
                  // after dropping finished tool calls
                  .rollingWindow(size: .entries(10))
                  .droppingCompletedToolCalls()
          }
      }
  }

// MARK: - [10:48] Lifecycle modifiers

// Lifecycle modifiers
  
  struct CraftProfile: LanguageModelSession.DynamicProfile {
      @SessionProperty(\.history) var history
      var orchestrator: CraftOrchestrator
      var body: some DynamicProfile {
          switch orchestrator.mode {
          case .planning:
              Profile { TutorialAuthor(orchestrator: orchestrator) }
                  .model(orchestrator.pccLanguageModel)
                  .reasoningLevel(.deep)
                  .onResponse {
                      // Update history
                      if history.count > 50, let responseIndex = lastResponseIndex(history) {
                          history = history[responseIndex...]
                      }
                  }
          }
      }
  }

// MARK: - [11:40] Declare a custom session property

// Session properties — declaration

  extension SessionPropertyValues {
      @SessionPropertyEntry var summary: String?
  }

// MARK: - [12:24] Read and write session properties in a profile

// Session properties
  
  struct CraftProfile: LanguageModelSession.DynamicProfile {
      @SessionProperty(\.history) var history
      @SessionProperty(\.summary) var summary
      var orchestrator: CraftOrchestrator
      var body: some DynamicProfile {
          switch orchestrator.mode {
          case .planning:
              Profile {
                  TutorialAuthor(orchestrator: orchestrator)
                  if let summary {
                      Instructions { "Summary: \(summary)" }
                  }
              }
              .onResponse {
                  if history.count > 50, let responseIndex = lastResponse(history.prefix(40)) {
                      summary = try await summarize(history[0..<responseIndex])
                      history = history[responseIndex...]
                  }
              }
          }
      }
  }

// MARK: - [13:02] Orchestration: baton-pass

// Baton-pass
  
  struct CraftProfile: LanguageModelSession.DynamicProfile {
      var orchestrator: CraftOrchestrator
      var body: some DynamicProfile {
          switch orchestrator.mode {
          case .brainstorm:
              Profile {
                  BrainstormInstructions()
                  BatonPassTool()
              }
              .onToolCall { orchestrator.mode = .tutorial }
              .model(orchestrator.serverModel)
          case .tutorial:
              Profile {
                  TutorialInstructions()
                  BatonPassTool()
              }
              .onToolCall { orchestrator.mode = .brainstorm }
              .model(orchestrator.systemModel)
          }
      }
  }

// MARK: - [14:14] Orchestration: phone-a-friend

// Phone-a-friend

  struct CraftProfile: LanguageModelSession.DynamicProfile {
      var body: some DynamicProfile {
          Profile {
              BrainstormInstructions()
              PhoneFriendTool(
                  name: "generate_title",
                  description: "Generate a creative project title",
                  profile: TitleProfile()
              )
          }
      }
  }

  struct PhoneFriendTool<P: LanguageModelSession.DynamicProfile>: Tool {
      func call(arguments: GeneratedContent) async throws -> String {
          let session = LanguageModelSession(profile: profile())
          let response = try await session.respond(to: arguments)
          return response.content
      }
  }

// MARK: - [15:15] The skills pattern

// The skills pattern
  
  struct CraftingSkills: LanguageModelSession.DynamicInstructions {
      var activations: SkillActivations
      var body: some DynamicInstructions {
          Skills(activations: activations) {
              Skill(
                  name: "origami_folds",
                  description: "Details about specific types of folds",
                  prompt: """
                      Valley Fold: Paper is folded toward you, creating a V-shaped crease
                      Mountain Fold: Paper is folded away from you, creating an inverted V
                      ...
                      """
              )
              Skill(...)
              Skill(...)
          }
      }
  }

// MARK: - [15:31] Tool calling mode

// Tool calling mode
  
  public struct ToolCallingMode: Sendable {
      public static let allowed: ToolCallingMode
      public static let disallowed: ToolCallingMode
      public static let required: ToolCallingMode
  }
  
  // Pass tool calling mode as a profile modifier
  struct OrigamiExpert: LanguageModelSession.DynamicProfile {
      var body: some LanguageModelSession.DynamicProfile {
          Profile {
              Instructions("You are an origami expert")
              QueryOrigamiDatabaseTool()
              ShowDirectionsTool()
          }
          .toolCallingMode(.required)
      }
  }

  // Or pass it as a generation option
  let response = try await session.respond(
      to: "Write out the instructions for folding a paper crane.",
      options: GenerationOptions(toolCallingMode: .required)
  )

// MARK: - [16:47] Escaping a tool call loop

// Escaping a tool call loop

  struct OrigamiExpert: LanguageModelSession.DynamicProfile {
      let state: OrigamiAppState

      var body: some LanguageModelSession.DynamicProfile {
          Profile {
              Instructions("Answer questions about how to fold origami")
              QueryOrigamiDatabaseTool()
          }
          .toolCallingMode(state.queriedDatabase ? .disallowed : .required)
          .onToolCall { state.queriedDatabase = true }
      }
  }

// MARK: - [16:57] Define a tool that throws an error

// Define a tool that throws an error
      var output: String?

      @Generable struct Arguments {
          var answer: String
      }

      func call(arguments: Arguments) async throws -> Never {
          output = arguments.answer
          throw CancellationError()
      }
  }

// MARK: - [17:28] Set the transcript error handling policy

// Specify transcript behavior on a profile
  struct OrigamiExpert: LanguageModelSession.DynamicProfile {
      let state: OrigamiAppState

      var body: some LanguageModelSession.DynamicProfile {
          Profile {
              Instructions("Answer questions about how to fold origami")
              QueryOrigamiDatabaseTool()
          }
          .transcriptErrorHandlingPolicy(.preserveTranscript)
      }
  }

  // Or specify it on a session
  let session = LanguageModelSession()
  session.transcriptErrorHandlingPolicy = .preserveTranscript

  // Policy options
  extension LanguageModelSession {
      public struct TranscriptErrorHandlingPolicy: Sendable {
          // Roll the transcript back to its previous state
          public static let revertTranscript: TranscriptErrorHandlingPolicy
          // Keep the transcript in state following an error
          public static let preserveTranscript: TranscriptErrorHandlingPolicy
      }
  }

// MARK: - [17:51] Transcript mutation

// Transcript mutation

  public final class LanguageModelSession: Sendable {
      public var transcriptErrorHandlingPolicy: TranscriptErrorHandlingPolicy { get set }

      // Transcript is now settable
      public var transcript: Transcript { get set }

      // But you must not modify it during a response!
      public var isResponding: Bool { get }
  }
