#if DEBUG
import Foundation

/// TEMPORARY — turns `SeedHistoryLog` into finished sessions, so the app
/// starts with Shota's last six months instead of an empty history.
/// `SwiftDataManager` imports them once per database in debug builds; it
/// never runs in release.
///
/// Each line of the log is one exercise on one day. Lines that share a date
/// become one session of the default workout that holds all their exercises
/// (Limbs, Back, Chest or Shoulder Day), in that workout's exercise order.
/// Strength sessions start at 18:00 and last 70–75 minutes, their sets
/// spread evenly across it; runs start at 12:30 as a "Treadmill Run"
/// session, MMA at 19:00 as an "MMA" session.
/// The "Planned" section puts workouts on days still to come.
enum SeedHistoryImporter {
    /// Every session in the log, built fresh. Ids come from each session's
    /// date and workout, so importing twice never adds anything twice, and
    /// `possibleSessionIDs` finds them again for a wipe.
    static func sessions() -> [WorkoutSession] {
        let log = parse(SeedHistoryLog.text)
        let all = strengthSessions(log.exercises)
            + cardioSessions(log.runs, exercise: "Running", workout: "Treadmill Run", key: "run", color: .mint, hour: 12, minute: 30)
            + cardioSessions(log.mma, exercise: "MMA", workout: "MMA", key: "mma", color: .orange, hour: 19, minute: 0)
            + plannedSessions(log.planned)
        return all.sorted { $0.scheduledFor < $1.scheduledFor }
    }

    /// Every id an import could ever have given a past session: each day from
    /// May 1 through Nov 2 — the last imported day — for each workout. Finds
    /// an earlier version of the history after the log changes. Sessions the
    /// user made never match (they get random ids), and Nov 4's Back Day — an
    /// imported plan the user then logged for real — is left alone.
    static var possibleSessionIDs: Set<UUID> {
        let calendar = WeekCalendar.calendar
        guard
            let first = calendar.date(from: DateComponents(year: year, month: 5, day: 1)),
            let last = calendar.date(from: DateComponents(year: year, month: 11, day: 2))
        else { return [] }
        let keys = DefaultWorkoutData.templates.map(\.name) + ["run", "mma"]
        var ids: Set<UUID> = []
        var day = first
        while day <= last {
            for key in keys {
                ids.insert(stableID("\(dayKey(day))|\(key)"))
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return ids
    }

    // MARK: - Log lines

    /// "Fri May 22 |  17.5 | 10 10 10 10 | medium", or with failed sets and
    /// no effort: "Fri May 29 |  17.5 | 10 10 9x 8x".
    private struct ExerciseLine {
        let exercise: String
        let day: Date
        /// The number entered; nil for bodyweight.
        let weight: Double?
        let sets: [SetLine]
        /// The effort footer's pick; nil when a set failed or none was given.
        let effort: Effort?
    }

    /// "9x" (9 reps, failed), "10", or "60s" (a hold).
    private struct SetLine {
        let reps: Int
        let failed: Bool
        let seconds: TimeInterval?
    }

    /// "Sat Oct 31 | 59:15 |  7.50 km |  7.6 km/h | HR 153", or for MMA
    /// "Tue Aug 25 | 90:00 | HR 153" (no distance).
    private struct CardioLine {
        let day: Date
        let seconds: TimeInterval
        let kilometers: Double?
        let heartRate: Double
    }

    /// "Wed Nov 04 | Back Day | planned"
    private struct PlannedLine {
        let day: Date
        let workout: String
    }

    private static let runSection = "Treadmill Run"
    private static let mmaSection = "MMA"
    private static let plannedSection = "Planned"
    private static let year = 2026

    private static func parse(_ text: String) -> (exercises: [ExerciseLine], runs: [CardioLine], mma: [CardioLine], planned: [PlannedLine]) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = WeekCalendar.calendar
        formatter.timeZone = .current
        formatter.dateFormat = "EEE MMM dd yyyy"

        var section = ""
        var exercises: [ExerciseLine] = []
        var runs: [CardioLine] = []
        var mma: [CardioLine] = []
        var planned: [PlannedLine] = []
        for raw in text.split(separator: "\n") {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("## ") {
                section = String(line.dropFirst(3))
                continue
            }
            let fields = line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
            guard fields.count >= 3, let day = formatter.date(from: "\(fields[0]) \(year)") else { continue }

            switch section {
            case runSection:
                guard
                    fields.count >= 5,
                    let seconds = clockSeconds(fields[1]),
                    let kilometers = Double(fields[2].replacingOccurrences(of: "km", with: "").trimmingCharacters(in: .whitespaces)),
                    let heartRate = heartRate(fields[4])
                else { continue }
                runs.append(CardioLine(day: day, seconds: seconds, kilometers: kilometers, heartRate: heartRate))
            case mmaSection:
                guard let seconds = clockSeconds(fields[1]), let heartRate = heartRate(fields[2]) else { continue }
                mma.append(CardioLine(day: day, seconds: seconds, kilometers: nil, heartRate: heartRate))
            case plannedSection:
                planned.append(PlannedLine(day: day, workout: fields[1]))
            default:
                let sets = fields[2].split(separator: " ").compactMap { setLine(String($0)) }
                // The footer only exists when every set was completed.
                let effort = fields.count >= 4 && !sets.contains(where: \.failed) ? Effort(rawValue: fields[3]) : nil
                exercises.append(ExerciseLine(exercise: section, day: day, weight: weight(fields[1]), sets: sets, effort: effort))
            }
        }
        return (exercises, runs, mma, planned)
    }

    /// "HR 153  intervals" → 153.
    private static func heartRate(_ text: String) -> Double? {
        text.split(separator: " ").dropFirst().first.flatMap { Double($0) }
    }

    /// "BW" → nil, "+5" → 5, "17.5" → 17.5.
    private static func weight(_ text: String) -> Double? {
        guard text != "BW" else { return nil }
        return Double(text.hasPrefix("+") ? String(text.dropFirst()) : text)
    }

    private static func setLine(_ text: String) -> SetLine? {
        if text.hasSuffix("s"), let seconds = Double(text.dropLast()) {
            return SetLine(reps: 0, failed: false, seconds: seconds)
        }
        let failed = text.hasSuffix("x")
        guard let reps = Int(failed ? String(text.dropLast()) : text) else { return nil }
        return SetLine(reps: reps, failed: failed, seconds: nil)
    }

    /// "59:15" → 3555.
    private static func clockSeconds(_ text: String) -> TimeInterval? {
        let parts = text.split(separator: ":").compactMap { Double($0) }
        guard parts.count == 2 else { return nil }
        return parts[0] * 60 + parts[1]
    }

    // MARK: - Sessions

    private static func strengthSessions(_ lines: [ExerciseLine]) -> [WorkoutSession] {
        let catalog = Dictionary(ExerciseData.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let byDay = Dictionary(grouping: lines, by: \.day)

        return byDay.keys.sorted().compactMap { day -> WorkoutSession? in
            let lines = byDay[day] ?? []
            let names = Set(lines.map(\.exercise))
            guard let template = DefaultWorkoutData.templates.first(where: { template in
                names.isSubset(of: Set(template.exercises.compactMap { catalog[$0.exerciseID]?.name }))
            }) else {
                assertionFailure("No default workout holds \(names.sorted()) on \(day)")
                return nil
            }

            let start = time(on: day, hour: 18, minute: 0)
            // 70–75 minutes, the same for a day on every import; the last set
            // lands two minutes before the end.
            let minutes = 70 + (WeekCalendar.calendar.ordinality(of: .day, in: .year, for: day) ?? 0) % 6
            let setCount = lines.reduce(0) { $0 + $1.sets.count }
            let setGap = (Double(minutes * 60) - 120) / Double(max(setCount, 1))
            var clock = start
            var exercises: [WorkoutExercise] = []
            for planned in template.exercises {
                guard
                    let name = catalog[planned.exerciseID]?.name,
                    let line = lines.first(where: { $0.exercise == name })
                else { continue }
                let sets = line.sets.enumerated().map { index, set in
                    clock += setGap
                    return SetEntry(
                        order: index,
                        reps: set.reps,
                        weight: line.weight,
                        loggedAt: clock,
                        failed: set.failed,
                        duration: set.seconds,
                    )
                }
                exercises.append(WorkoutExercise(exerciseID: planned.exerciseID, order: exercises.count, sets: sets, effort: line.effort))
            }

            var workout = template
            workout.exercises = exercises
            return WorkoutSession(
                id: stableID("\(dayKey(day))|\(template.name)"),
                workout: workout,
                scheduledFor: day,
                startedAt: start,
                endedAt: start.addingTimeInterval(Double(minutes * 60)),
            )
        }
    }

    /// One finished cardio session per line, as a one-exercise cardio
    /// workout named `workout`.
    private static func cardioSessions(
        _ lines: [CardioLine],
        exercise name: String,
        workout: String,
        key: String,
        color: WorkoutColor,
        hour: Int,
        minute: Int,
    ) -> [WorkoutSession] {
        guard let exercise = ExerciseData.exercises.first(where: { $0.name == name }) else { return [] }
        return lines.map { line in
            let start = time(on: line.day, hour: hour, minute: minute)
            let cardio = CardioEntry(
                duration: line.seconds,
                speedKmh: line.kilometers.map { $0 / (line.seconds / 3600) },
                distanceMeters: line.kilometers.map { $0 * 1000 },
                startedAt: start,
                averageHeartRate: line.heartRate,
            )
            let template = WorkoutTemplate(
                id: stableID("\(key)-workout"),
                name: workout,
                color: color,
                type: .cardio,
                primaryMuscleGroup: .fullBody,
                exercises: [WorkoutExercise(exerciseID: exercise.id, order: 0, cardio: cardio)],
            )
            return WorkoutSession(
                id: stableID("\(dayKey(line.day))|\(key)"),
                workout: template,
                scheduledFor: line.day,
                startedAt: start,
                endedAt: start.addingTimeInterval(line.seconds),
            )
        }
    }

    /// Default workouts put on days still to come; they follow the workout.
    private static func plannedSessions(_ lines: [PlannedLine]) -> [WorkoutSession] {
        lines.compactMap { line in
            guard let template = DefaultWorkoutData.templates.first(where: { $0.name == line.workout }) else {
                assertionFailure("Unknown planned workout \(line.workout)")
                return nil
            }
            return WorkoutSession(
                id: stableID("\(dayKey(line.day))|\(template.name)"),
                workout: template,
                scheduledFor: line.day,
                followsWorkout: true,
            )
        }
    }

    // MARK: - Helpers

    private static func time(on day: Date, hour: Int, minute: Int) -> Date {
        WeekCalendar.calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// "2026-05-22".
    private static func dayKey(_ day: Date) -> String {
        let parts = WeekCalendar.calendar.dateComponents([.year, .month, .day], from: day)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// The same id for the same key on every run: two FNV-1a hashes laid out
    /// as a UUID.
    private static func stableID(_ key: String) -> UUID {
        var first: UInt64 = 0xCBF2_9CE4_8422_2325
        var second: UInt64 = 0x6C62_272E_07BB_0142
        for byte in "fittap-seed|\(key)".utf8 {
            first = (first ^ UInt64(byte)) &* 0x0000_0100_0000_01B3
            second = (second ^ UInt64(byte)) &* 0x0000_0100_0000_01B3 &+ 0x9E37_79B9_7F4A_7C15
        }
        let hex = Array(String(format: "%016llX%016llX", first, second))
        let groups = [0..<8, 8..<12, 12..<16, 16..<20, 20..<32].map { String(hex[$0]) }
        return UUID(uuidString: groups.joined(separator: "-")) ?? UUID()
    }
}
#endif
