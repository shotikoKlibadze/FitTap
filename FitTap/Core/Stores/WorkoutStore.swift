import FactoryKit
import Foundation

/// Every workout the user can start or plan, saved in the database, in the
/// order they were made. One instance for the app (see
/// `Container.workoutStore`).
@MainActor
@Observable
final class WorkoutStore {
    @ObservationIgnored @Injected(\.swiftDataManager) private var database
    @ObservationIgnored @Injected(\.workoutSessionStore) private var sessionStore

    private(set) var templates: [WorkoutTemplate] = []

    init() {
        templates = database.templates()
    }

    func template(id: UUID) -> WorkoutTemplate? {
        templates.first { $0.id == id }
    }

    /// Saves a new workout and adds it to the end of the list.
    func add(_ template: WorkoutTemplate) {
        database.save(template)
        templates.append(template)
    }

    /// Saves the workout with the same id; unknown ids are ignored. Planned
    /// sessions following it pick up the change.
    func update(_ template: WorkoutTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }
        database.save(template)
        templates[index] = template
        sessionStore.reload()
    }

    /// Deletes the workout. Its planned days keep a copy and stay on the
    /// calendar; logged sessions are untouched.
    func remove(id: UUID) {
        database.deleteTemplate(id: id)
        templates.removeAll { $0.id == id }
        sessionStore.reload()
    }
}
