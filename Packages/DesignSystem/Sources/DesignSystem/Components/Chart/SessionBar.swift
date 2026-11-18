import Foundation

/// One bar of a `SessionBarChart`: one session of an exercise.
///
/// Plain values only, so the chart knows nothing about workouts: how tall
/// the bar is (`value`, in whatever the exercise is measured in), the day
/// under it (`label`), and how the session went (`kind`), which picks the
/// bar's colour.
public struct SessionBar: Identifiable, Hashable, Sendable {
    /// How a session went, as the chart colours it.
    public enum Kind: Hashable, Sendable {
        /// Every set was finished: a solid green bar.
        case clean
        /// At least one set failed: a hollow red bar.
        case failed
    }

    public let id: UUID
    public let value: Double
    public let label: String
    public let kind: Kind

    public init(id: UUID = UUID(), value: Double, label: String, kind: Kind) {
        self.id = id
        self.value = value
        self.label = label
        self.kind = kind
    }
}

#if DEBUG
public extension SessionBar {
    /// Fourteen sessions, oldest first: a slow climb with a few failed
    /// sessions.
    static let samples: [SessionBar] = [
        SessionBar(value: 15, label: "Jul 20", kind: .clean),
        SessionBar(value: 15, label: "Jul 23", kind: .clean),
        SessionBar(value: 17.5, label: "Jul 27", kind: .failed),
        SessionBar(value: 17.5, label: "Jul 30", kind: .clean),
        SessionBar(value: 17.5, label: "Aug 3", kind: .clean),
        SessionBar(value: 17.5, label: "Aug 6", kind: .clean),
        SessionBar(value: 17.5, label: "Aug 10", kind: .clean),
        SessionBar(value: 17.5, label: "Aug 13", kind: .clean),
        SessionBar(value: 20, label: "Aug 17", kind: .failed),
        SessionBar(value: 20, label: "Aug 20", kind: .clean),
        SessionBar(value: 22.5, label: "Aug 24", kind: .clean),
        SessionBar(value: 20, label: "Aug 27", kind: .failed),
        SessionBar(value: 20, label: "Aug 31", kind: .clean),
        SessionBar(value: 20, label: "Sep 2", kind: .clean),
    ]
}
#endif
