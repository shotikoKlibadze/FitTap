import DesignSystem
import SwiftUI

/// The fourth onboarding page: the workout card plays itself on a loop —
/// three sets checked, "How did it feel?" slides out, the rating moves Hard,
/// Medium, then lands on Easy, and the suggestion that earns appears — over
/// "Say how it felt." Watch-only: nothing takes touches.
struct OnboardingRateStep: View {
    @State private var bench = Self.freshBench
    @State private var showsSuggestion = false

    private static let exercise = ExerciseData.exercises.first { $0.name == "Bench Press" }
        ?? Exercise(name: "Bench Press", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .chest)

    private static var freshBench: WorkoutExercise {
        WorkoutExercise(
            exerciseID: exercise.id,
            order: 0,
            sets: (0..<3).map { SetEntry(order: $0, reps: 10, weight: 20) },
        )
    }

    /// Everything the loop ends on, unseen, so the page keeps its size while
    /// the strip and the suggestion come and go.
    private static var finishedBench: WorkoutExercise {
        var bench = freshBench
        for index in bench.sets.indices {
            bench.sets[index].loggedAt = .distantPast
        }
        bench.effort = .easy
        return bench
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                demo(bench: .constant(Self.finishedBench), showsSuggestion: true)
                    .hidden()
                demo(bench: $bench, showsSuggestion: showsSuggestion)
            }
            .allowsHitTesting(false)
            Text("Say how it felt.")
                .font(FTFonts.title2Bold)
                .foregroundStyle(FTColors.textPrimary)
                .padding(.top, 36)
            Text("After the last set, one tap: Easy, Medium or Hard. FitTap uses it to know when you're ready for more weight, and when to hold.")
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .task { await play() }
    }

    private func demo(bench: Binding<WorkoutExercise>, showsSuggestion: Bool) -> some View {
        VStack(spacing: 0) {
            ExerciseCard(
                exercise: Self.exercise,
                workoutExercise: bench,
                mode: .session,
                isScripted: true,
                onTapReps: { _ in },
                onTapWeight: { _ in },
                onTapSuggestion: {},
                onRemoveExercise: {},
            )
            .zIndex(1)
            // As while working out: the strip slides out from behind the
            // card once every set is checked.
            if bench.wrappedValue.allSetsCompleted {
                RatingStrip(
                    prompt: "How did it feel?",
                    options: Effort.ratingOptions,
                    selectedID: bench.effort.ratingID,
                )
                .padding(.horizontal, RatingStrip.sideInset)
                .padding(.top, -RatingStrip.cardOverlap)
                .transition(.move(edge: .top))
            }
            if showsSuggestion {
                SuggestionCard(
                    title: "Bench Press felt easy 3 times at 20 kg",
                    message: "Try 22.5 kg next Push Day.",
                )
                .padding(.top, 12)
                .transition(.scale(scale: 0.9, anchor: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4), value: bench.wrappedValue.allSetsCompleted)
    }

    /// The demo, over and over until the page goes away.
    private func play() async {
        do {
            while true {
                try await Task.sleep(for: .seconds(0.9))
                for index in bench.sets.indices {
                    log(set: index)
                    try await Task.sleep(for: .seconds(0.7))
                }
                try await Task.sleep(for: .seconds(0.6))
                for effort in [Effort.hard, .medium, .easy] {
                    withAnimation(.smooth(duration: 0.25)) { bench.effort = effort }
                    try await Task.sleep(for: .seconds(0.8))
                }
                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.05)) { showsSuggestion = true }
                try await Task.sleep(for: .seconds(2.8))
                withAnimation(.smooth(duration: 0.4)) {
                    showsSuggestion = false
                    bench = Self.freshBench
                }
            }
        } catch {
            // Cancelled: the page left.
        }
    }

    private func log(set index: Int) {
        withAnimation(.smooth(duration: 0.2)) {
            bench.sets[index].loggedAt = .now
        }
    }
}

#if DEBUG
private struct OnboardingRateStepPreviewHost: View {
    var body: some View {
        OnboardingRateStep()
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingRateStepPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingRateStepPreviewHost()
        .preferredColorScheme(.light)
}
#endif
