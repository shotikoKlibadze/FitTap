import DesignSystem
import SwiftUI

struct NewWorkoutView: View {
    @Binding var name: String
    @Binding var type: WorkoutType
    @Binding var color: WorkoutColor
    @Binding var primaryMuscleGroup: MuscleGroup?
    @Binding var secondaryMuscleGroup: MuscleGroup?
    @Binding var exercises: [WorkoutExercise]
    let catalog: [UUID: Exercise]
    let canCreate: Bool
    let onTapAddExercise: () -> Void
    /// (workout exercise id, set id)
    let onTapReps: (UUID, UUID) -> Void
    let onTapWeight: (UUID, UUID) -> Void
    /// Cardio duration / speed pill tapped for the workout exercise with this id.
    let onTapDuration: (UUID) -> Void
    let onTapSpeed: (UUID) -> Void
    let onRemoveExercise: (UUID) -> Void
    let onTapCreate: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                WorkoutNameField(name: $name, color: $color)
                    .zIndex(2) // open color palette floats over the sections below

                section("Type") {
                    SegmentedToggle(
                        options: ["Strength", "Cardio"],
                        selectedIndex: Binding(
                            get: { type == .strength ? 0 : 1 },
                            set: { type = $0 == 0 ? .strength : .cardio },
                        ),
                    )
                }

                section("Muscle Groups") {
                    HStack(alignment: .top, spacing: 10) {
                        MuscleGroupPickerCard(
                            label: "Primary",
                            isOptional: false,
                            selection: $primaryMuscleGroup,
                            isLocked: type == .cardio, // cardio is always full body
                        )
                        if type == .strength {
                            MuscleGroupPickerCard(label: "Secondary", isOptional: true, selection: $secondaryMuscleGroup)
                                .transition(.opacity)
                        }
                    }
                }
                .zIndex(1) // open picker floats over the sections below
                .animation(.smooth(duration: 0.3), value: type)

                if exercises.isEmpty {
                    CardAddButton(
                        title: "Add Exercise",
                        subtitle: "Add your first exercise to start building the workout.",
                        height: 170,
                        action: onTapAddExercise,
                    )
                } else {
                    section("Exercises") {
                        VStack(spacing: 12) {
                            ForEach($exercises) { $workoutExercise in
                                if let exercise = catalog[workoutExercise.exerciseID] {
                                    ExerciseCard(
                                        exercise: exercise,
                                        workoutExercise: $workoutExercise,
                                        onTapReps: { setID in onTapReps(workoutExercise.id, setID) },
                                        onTapWeight: { setID in onTapWeight(workoutExercise.id, setID) },
                                        onTapDuration: { onTapDuration(workoutExercise.id) },
                                        onTapSpeed: { onTapSpeed(workoutExercise.id) },
                                        onTapSuggestion: {},
                                        onRemoveExercise: { onRemoveExercise(workoutExercise.id) },
                                    )
                                    .transition(.opacity)
                                }
                            }
                            CardAddButton(title: "Add Exercise", height: 110, action: onTapAddExercise)
                        }
                    }
                }
            }
            .animation(.smooth(duration: 0.3), value: exercises.map(\.id))
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
        // Room to scroll the last card clear of the Create button and its fade.
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .bottomActionBar {
            PillButton(title: "Create workout", disabled: !canCreate, action: onTapCreate)
        }
        .background(FTColors.background)
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: title)
            content()
        }
    }
}

#if DEBUG
private struct NewWorkoutViewPreviewHost: View {
    @State private var name = ""
    @State private var type = WorkoutType.strength
    @State private var color = WorkoutColor.navy
    @State private var primary: MuscleGroup?
    @State private var secondary: MuscleGroup?
    @State private var exercises: [WorkoutExercise] = []

    private let catalog = Dictionary(uniqueKeysWithValues: ExerciseData.exercises.map { ($0.id, $0) })

    var body: some View {
        NavigationStack {
            NewWorkoutView(
                name: $name,
                type: $type,
                color: $color,
                primaryMuscleGroup: $primary,
                secondaryMuscleGroup: $secondary,
                exercises: $exercises,
                catalog: catalog,
                canCreate: !exercises.isEmpty,
                onTapAddExercise: addNextExercise,
                onTapReps: { _, _ in },
                onTapWeight: { _, _ in },
                onTapDuration: { _ in },
                onTapSpeed: { _ in },
                onRemoveExercise: { id in exercises.removeAll { $0.id == id } },
                onTapCreate: {},
            )
        }
    }

    /// Stands in for the Add Exercise screen: adds the next catalog exercise.
    private func addNextExercise() {
        let exercise = ExerciseData.exercises[exercises.count % ExerciseData.exercises.count]
        let weight: Double? = exercise.kind == .weightlifting ? 10 : nil
        exercises.append(WorkoutExercise(
            exerciseID: exercise.id,
            order: exercises.count,
            sets: [SetEntry(order: 0, reps: 10, weight: weight)],
        ))
    }
}
#Preview("Light") {
    NewWorkoutViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    NewWorkoutViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
