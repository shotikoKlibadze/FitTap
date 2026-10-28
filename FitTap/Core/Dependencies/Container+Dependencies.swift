import FactoryKit

extension Container {
    // Registrations live here — one file for the whole dependency graph.

    /// Built-in and user-created exercises, shared by every screen that
    /// lists or looks up exercises.
    @MainActor
    var exerciseStore: Factory<ExerciseStore> {
        self { MainActor.assumeIsolated { ExerciseStore() } }
            .singleton
    }

    /// Workout templates — what the Workouts tab lists and Home plans from.
    @MainActor
    var workoutStore: Factory<WorkoutStore> {
        self { MainActor.assumeIsolated { WorkoutStore() } }
            .singleton
    }

    /// Dated sessions — planned, done and missed — behind the Home week strip.
    @MainActor
    var workoutSessionStore: Factory<WorkoutSessionStore> {
        self { MainActor.assumeIsolated { WorkoutSessionStore() } }
            .singleton
    }
}
