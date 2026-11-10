import Foundation

/// Which way an exercise is going, latest session against the one before.
enum ProgressTrend: Sendable {
    case up
    case flat
    case down
}
