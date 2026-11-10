import SwiftData

/// How the database moves between schema versions. Only V1 exists, so there
/// are no stages yet; the plan is in place so the first change after
/// release is a stage, not a rewrite.
nonisolated enum FitTapMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }

    static var stages: [MigrationStage] { [] }
}
