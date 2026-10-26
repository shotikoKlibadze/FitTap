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
}
