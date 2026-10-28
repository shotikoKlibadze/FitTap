import DesignSystem
import SwiftUI

/// A `WorkoutSession` reduced to what `WorkoutSessionCard` draws: title, dot,
/// date, a row of stats and the status. Built once by the screen model so
/// the view stays free of formatting.
struct SessionCardItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let dotColor: Color
    let dateText: String
    let stats: [String]
    let status: WorkoutSessionCard.Status

    init(session: WorkoutSession) {
        id = session.id
        title = session.workout.name
        dotColor = session.workout.color.color
        dateText = session.scheduledFor.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
        status = switch session.status {
        case .done: .done
        case .planned: .planned
        case .missed: .missed
        }
        stats = Self.stats(for: session)
    }

    /// Done: how long it took and what was in it ("58 min · 6 exercises ·
    /// 21 sets", "34 min · 6.2 km · 5:29 /km"). Planned: what's in it and a
    /// rough length. Missed: just what was in it.
    private static func stats(for session: WorkoutSession) -> [String] {
        let exercises = session.workout.exercises
        switch session.workout.type {
        case .cardio:
            let efforts = exercises.compactMap(\.cardio)
            let seconds = efforts.reduce(0) { $0 + $1.duration }
            let meters = efforts.compactMap(\.distanceMeters).reduce(0, +)
            var stats = [minutes(seconds)]
            if meters > 0 {
                if session.status == .done {
                    stats.append(kilometers(meters))
                    stats.append(pace(seconds: seconds, meters: meters))
                } else {
                    stats.append("\(kilometers(meters)) target")
                }
            }
            return stats
        case .strength:
            var stats: [String] = []
            if session.status == .done, let start = session.startedAt, let end = session.endedAt {
                stats.append(minutes(end.timeIntervalSince(start)))
            }
            stats.append("\(exercises.count) exercises")
            stats.append("\(session.workout.setCount) sets")
            if session.status == .planned {
                stats.append("~\(session.workout.estimatedMinutes) min")
            }
            return stats
        }
    }

    private static func minutes(_ seconds: TimeInterval) -> String {
        "\(Int((seconds / 60).rounded())) min"
    }

    private static func kilometers(_ meters: Double) -> String {
        "\((meters / 1000).formatted(.number.precision(.fractionLength(0...1)))) km"
    }

    private static func pace(seconds: TimeInterval, meters: Double) -> String {
        let secondsPerKm = Int((seconds / (meters / 1000)).rounded())
        return "\(secondsPerKm / 60):\(String(format: "%02d", secondsPerKm % 60)) /km"
    }
}

#if DEBUG
extension SessionCardItem {
    static let samples: [SessionCardItem] = WorkoutSessionData.sessions.map { SessionCardItem(session: $0) }
}
#endif
