// What’s new in watchOS 26
// WWDC25 session 334 · https://developer.apple.com/videos/play/wwdc2025/334/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [6:53] Make a widget configurable

// In the AppIntentTimelineProvider
func recommendations() -> [AppIntentRecommendation<BeachConfigurationIntent>] {
  return []
}

// MARK: - [7:06] Support earlier versions of watchOS with a configurable widget

// In the AppIntentTimelineProvider
func recommendations() -> [AppIntentRecommendation<BeachConfigurationIntent>] {
  if #available(watchOS 26, *) {
    // Return an empty array to allow configuration of the widget in watchOS 12+
    return []
  } else {
    // Return array of recommendations for preconfigured widgets before watchOS 12
    return recommendedBeaches
  }
}

// MARK: - [7:46] Use AppIntentControlConfiguration to make a control configurable

struct ConfigurableMeditationControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    AppIntentControlConfiguration(
      kind: WidgetKinds.configurableMeditationControl,
      provider: Provider()
    ) { value in
      // Provide the control's content
    }
    .displayName("Ocean Meditation")
    .description("Meditation with optional ocean sounds.")
    .promptsForUserConfiguration()
  }
}

// MARK: - [7:56] Use AppIntentControlValueProvider for a configurable control

extension ConfigurableMeditationControl {
  struct Provider: AppIntentControlValueProvider {
    func previewValue(configuration: TimerConfiguration) -> Value {
      // Return the value to show in the add sheet
    }

    func currentValue(configuration: TimerConfiguration) async throws -> Value {
      // Return the control's value
    }
  }
}

// MARK: - [10:53] Relevance for a point-of-interest category

func relevance() async -> WidgetRelevance<Void> {
  guard let context = RelevantContext.location(category: .beach) else {
    return WidgetRelevance<Void>([])
  }
  return WidgetRelevance([WidgetRelevanceAttribute(context: context)])
}

// MARK: - [14:37] Implement the relevance method in the RelevanceEntriesProvider

struct BeachEventRelevanceProvider: RelevanceEntriesProvider {
  let store: BeachEventStore

  func relevance() async -> WidgetRelevance<BeachEventConfigurationIntent> {
    // Associate configuration intents with RelevantContexts
    let attributes = events.map { event in
      WidgetRelevanceAttribute(
        configuration: BeachEventConfigurationIntent(event: event),
        context: .date(interval: event.date, kind: .default)
      )
    }

    return WidgetRelevance(attributes)
  }
}

// MARK: - [15:09] Create a RelevanceEntry when the widget is relevant

struct BeachEventRelevanceProvider: RelevanceEntriesProvider {
  func relevance() async -> WidgetRelevance<BeachEventConfigurationIntent> {
    // Return relevance information for the widget
  }
  
  func entry(
    configuration: BeachEventConfigurationIntent,
    context: Context
  ) async throws -> BeachEventRelevanceEntry {
    if context.isPreview {
      return .previewEntry
    }
    return BeachEventRelevanceEntry(
      event: configuration.event
    )
  }
}

// MARK: - [15:55] Create a placeholder entry to display when the widget is loading

struct BeachEventRelevanceProvider: RelevanceEntriesProvider {
  func relevance() async -> WidgetRelevance<BeachEventConfigurationIntent> {
    // Return relevance information for the widget
  }
  
  func entry(
    configuration: BeachEventConfigurationIntent,
    context: Context
  ) async throws -> BeachEventRelevanceEntry {
    // Return the entry for the configuration
  }
  
  func placeholder(context: Context) -> BeachEventRelevanceEntry {
    BeachEventRelevanceEntry.placeholderEntry
  }
}

// MARK: - [16:27] Use a RelevanceConfiguration to create a relevant widget

struct BeachEventWidget: Widget {
  private let model = BeachEventStore.shared

  var body: some WidgetConfiguration {
    RelevanceConfiguration
      kind: "BeachWidget
      provider: BeachEventRelevanceProvider(store: model)
    ) { entry in
      BeachWidgetView(entry: entry)
    }
    .configurationDisplayName("Beach Events")
    .description("Events at the beach")
  }
}

// MARK: - [17:31] Use associatedKind to relate the relevant widget to the timeline widget

struct BeachEventWidget: Widget {
  private let model = BeachEventStore.shared

  var body: some WidgetConfiguration {
    RelevanceConfiguration
      kind: "BeachWidget
      provider: BeachEventRelevanceProvider(store: model)
    ) { entry in
      BeachWidgetView(entry: entry)
    }
    .configurationDisplayName("Beach Events")
    .description("Events at the beach")
    .associatedKind(WidgetKinds.beachEventsTimeline)
  }
}

// MARK: - [18:06] Create a Preview with relevanceEntries

#Preview("Entries") {
  BeachEventWidget()
} relevanceEntries: {
  BeachEventRelevanceEntry.previewShorebirds
  BeachEventRelevanceEntry.previewMeditation
}

// MARK: - [18:26] Create a Preview with relevance

#Preview("Provider and Relevance") {
  BeachEventWidget()
} relevanceProvider: {
  BeachEventRelevanceProvider(store: .preview)
} relevance: {
  let configurations: [BeachEventConfigurationIntent] = [
    .previewSurfing,
    .previewMeditation,
    .previewWalk
  ]
  let attributes = configurations.map {
    WidgetRelevanceAttribute(
      configuration: $0,
      context: .date($0.event.startDate, kind: .default)
    )
  }
  return WidgetRelevance(attributes)
}

// MARK: - [18:47] Create a Preview with a relevanceProvider

#Preview("Provider") {
  BeachEventWidget()
} relevanceProvider: {
  BeachEventRelevanceProvider(store: .preview)
}
