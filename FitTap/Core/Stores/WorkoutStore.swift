import Foundation

/// Every workout the user can start or plan: the built-in templates plus the
/// ones they create. In memory for now — SwiftData takes over when
/// persistence lands. One instance for the app (see `Container.workoutStore`).
@MainActor
@Observable
final class WorkoutStore {
    private(set) var templates: [WorkoutTemplate] = WorkoutData.templates

    func template(id: UUID) -> WorkoutTemplate? {
        templates.first { $0.id == id }
    }

    func add(_ template: WorkoutTemplate) {
        templates.append(template)
    }

    /// Replaces the template with the same id; unknown ids are ignored.
    func update(_ template: WorkoutTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[index] = template
    }
}
