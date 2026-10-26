// What’s new in the Foundation Models framework
// WWDC26 session 241 · https://developer.apple.com/videos/play/wwdc2026/241/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [2:46] Context size and token counting

// Context size and token counting
  
  let model = SystemLanguageModel()
  print(model.contextSize)
  // 8192
  
  let count = try await model.tokenCount(for: "What are the Japanese characters for origami?")
  print(count)

// MARK: - [3:52] Attachable image types

// Insert c// Attachable image types

  let response = try await session.respond {
      "What animal is this?"
      Attachment(UIImage(...))
  }ode snippet.

// MARK: - [8:45] Inspecting usage

// Inspecting usage
  
  let response = try await session.respond(
      to: "Recommend a craft that doesn't require scissors.",
      contextOptions: ContextOptions(reasoningLevel: .light)
  )

  print(response.usage.input.totalTokenCount)
  print(response.usage.input.cachedTokenCount)

  print(response.usage.output.totalTokenCount)
  print(response.usage.output.reasoningTokenCount)

// MARK: - [11:55] Routing between craft analysis and brainstorm

// Routing between craft analysis and brainstorm
  
  @Observable
  final class AppStates {
      var mode: Mode
  }

  let appStates: AppStates
  var session: LanguageModelSession?

  func updateSession() {
      let originalTranscript = session?.transcript.dropFirstInstructions() ?? Transcript()

      // Create a new session with new instructions and tools
      switch appStates.mode {
      case .craftAnalysis:
          session = LanguageModelSession(
              tools: [
                  RecordImageAnalysisTool(),
                  SwitchModeTool(states: appStates)
              ],
              instructions: "Analyze the user's craft project...",
              transcript: originalTranscript
          )
      case .brainstorm:
          session = LanguageModelSession(
              tools: [
                  RecordBrainstormTool(),
              ],
              instructions: "Brainstorm some ideas...",
              transcript: originalTranscript
          )
      }
  }
  
  struct SwitchModeTool: Tool {
      let description = "Switch to a different mode."
      let states: AppStates

      @Generable
      struct Arguments {
          let mode: Mode
      }

      func call(arguments: Arguments) async throws -> some PromptRepresentable {
          appStates.mode = arguments.mode
          return "Successfully switched to \(arguments.mode)."
      }
  }
  
  // If mode changes, update the session
  withObservationTracking {
      appStates.mode
  } onChange: {
      updateSession()
  }

// MARK: - [12:42] Describing the profile for craft app

// Describing the profile for craft app

  struct CraftProfile: LanguageModelSession.DynamicProfile {
      var body: some DynamicProfile {
          Profile {
              Instructions {
                  """
                  You are an expert crafting assistant. \
                  Record craft project image analyses   \
                  using the recordImageAnalysis tool.
                  """
              }
              RecordImageAnalysisTool()
          }
      }
  }

  let session = LanguageModelSession(
      profile: CraftProfile()
  )

// MARK: - [14:36] Describing the profile for craft app

// Describing the profile for craft app
  
  struct CraftProfile: LanguageModelSession.DynamicProfile {
      let states: CraftProjectStates

      var body: some DynamicProfile {
          switch states.mode {
          case .craftAnalysis:
              Profile {
                  Instructions { /* ... */ }
                  RecordImageAnalysisTool()
                  SwitchModeTool(states: states)
              }
          case .brainstorm:
              Profile {
                  Instructions { /* ... */ }
                  BrainstormRecordTool()
              }
              .model(states.privateCloudCompute)
              .reasoningLevel(.deep)
          }
      }
  }

// MARK: - [18:29] Foundation Models SDK for Python

# Foundation Models SDK for Python
  
  import apple_fm_sdk as fm

  model = fm.SystemLanguageModel()

  # Check the model's availability
  is_available, reason = model.is_available()

  if is_available:

      # Create a session
      session = fm.LanguageModelSession(model=model)

      # Generate a response
      response = await session.respond(prompt="Hello!")
      print(response)
