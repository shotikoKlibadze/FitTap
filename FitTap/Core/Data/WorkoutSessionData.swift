import Foundation

/// Three weeks of hardcoded sessions around today — last week logged (with
/// one skipped day), this week logged up to yesterday, next week planned.
/// Built relative to the current date so the strip always reads right.
enum WorkoutSessionData {
    static let sessions: [WorkoutSession] = {
        let calendar = WeekCalendar.calendar
        let today = calendar.startOfDay(for: .now)
        let thisMonday = WeekCalendar.startOfWeek(containing: today)

        func day(week: Int, weekday: Int) -> Date {
            calendar.date(byAdding: .day, value: week * 7 + weekday, to: thisMonday)!
        }

        func template(_ name: String) -> WorkoutTemplate {
            guard let template = WorkoutData.templates.first(where: { $0.name == name }) else {
                fatalError("Unknown workout in WorkoutSessionData: \(name)")
            }
            return template
        }

        func planned(_ name: String, on date: Date) -> WorkoutSession {
            WorkoutSession(workout: template(name), scheduledFor: date)
        }

        /// A finished session: started at six in the evening, ran `minutes`;
        /// a cardio one also records how far it went.
        func done(_ name: String, on date: Date, minutes: Double, kilometers: Double? = nil) -> WorkoutSession {
            var workout = template(name)
            let start = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
            let end = start.addingTimeInterval(minutes * 60)
            if let kilometers {
                for index in workout.exercises.indices where workout.exercises[index].cardio != nil {
                    workout.exercises[index].cardio = CardioEntry(
                        duration: minutes * 60,
                        speedKmh: kilometers / (minutes / 60),
                        distanceMeters: kilometers * 1000,
                        startedAt: start,
                    )
                }
            }
            return WorkoutSession(workout: workout, scheduledFor: date, startedAt: start, endedAt: end)
        }

        // Last week: four on the plan, Wednesday skipped.
        var sessions = [
            done("Push Day", on: day(week: -1, weekday: 0), minutes: 58),
            planned("Pull Day", on: day(week: -1, weekday: 2)),
            done("Leg Day", on: day(week: -1, weekday: 4), minutes: 62),
            done("Easy 6 km", on: day(week: -1, weekday: 5), minutes: 34, kilometers: 6.2),
        ]

        // This week: whatever already passed is logged (Friday's run skipped),
        // today is left open, the rest stays planned.
        let thisWeek: [(weekday: Int, name: String, minutes: Double, kilometers: Double?, happened: Bool)] = [
            (0, "Back Day", 55, nil, true),
            (2, "Push Day", 51, nil, true),
            (4, "Easy 6 km", 31, 5.8, false),
            (6, "Leg Day", 60, nil, true),
        ]
        for entry in thisWeek {
            let date = day(week: 0, weekday: entry.weekday)
            if date == today { continue }
            if date < today, entry.happened {
                sessions.append(done(entry.name, on: date, minutes: entry.minutes, kilometers: entry.kilometers))
            } else {
                sessions.append(planned(entry.name, on: date))
            }
        }

        // Next week: all planned.
        sessions += [
            planned("Push Day", on: day(week: 1, weekday: 0)),
            planned("Pull Day", on: day(week: 1, weekday: 2)),
            planned("Leg Day", on: day(week: 1, weekday: 4)),
            planned("Sparring", on: day(week: 1, weekday: 5)),
        ]
        return sessions
    }()
}
