import SwiftData

/// The first version of the database. Until the first release (TestFlight or
/// real personal data) it's simply whatever the entities are; after that,
/// every model change becomes a new version and a migration stage.
nonisolated enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            ExerciseEntity.self,
            WorkoutTemplateEntity.self,
            WorkoutSessionEntity.self,
            WorkoutExerciseEntity.self,
            SetEntryEntity.self,
        ]
    }
}
