import DesignSystem
import SwiftUI

/// One exercise while working out: its card, and under it — once every set
/// is checked and none failed — the "How did it feel?" tab tucked behind the
/// card's bottom edge. A failed set already says it was hard, so it gets no
/// tab. Unchecking a set slides the tab back up; the two move as one piece.
struct SessionExerciseCard: View {
    let exercise: Exercise
    @Binding var workoutExercise: WorkoutExercise
    /// Set id of the reps / weight pill tapped.
    let onTapReps: (UUID) -> Void
    let onTapWeight: (UUID) -> Void
    let onTapDuration: () -> Void
    let onTapSpeed: () -> Void
    /// A rating was picked — the owner moves on to the next exercise.
    let onRated: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ExerciseCard(
                exercise: exercise,
                workoutExercise: $workoutExercise,
                mode: .session,
                onTapReps: onTapReps,
                onTapWeight: onTapWeight,
                onTapDuration: onTapDuration,
                onTapSpeed: onTapSpeed,
                onTapSuggestion: {},
                onRemoveExercise: {},
            )
            .zIndex(1)
            if workoutExercise.allSetsCompleted {
                RatingStrip(
                    prompt: "How did it feel?",
                    options: Effort.ratingOptions,
                    selectedID: $workoutExercise.effort.ratingID,
                )
                .padding(.horizontal, RatingStrip.sideInset)
                .padding(.top, -RatingStrip.cardOverlap)
                .transition(.move(edge: .top))
            }
        }
        .animation(.spring(duration: 0.4), value: workoutExercise.allSetsCompleted)
        .onChange(of: workoutExercise.effort) { _, effort in
            if effort != nil { onRated() }
        }
    }
}

#if DEBUG
private struct SessionExerciseCardPreviewHost: View {
    @State private var workoutExercise = WorkoutExercise(
        exerciseID: Exercise.sample.id,
        order: 0,
        sets: [
            SetEntry(order: 0, reps: 8, weight: 20, loggedAt: .now),
            SetEntry(order: 1, reps: 8, weight: 20, loggedAt: .now),
            SetEntry(order: 2, reps: 8, weight: 20),
        ],
    )

    var body: some View {
        SessionExerciseCard(
            exercise: .sample,
            workoutExercise: $workoutExercise,
            onTapReps: { _ in },
            onTapWeight: { _ in },
            onTapDuration: {},
            onTapSpeed: {},
            onRated: {},
        )
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Dark") {
    SessionExerciseCardPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    SessionExerciseCardPreviewHost()
        .preferredColorScheme(.light)
}
#endif
