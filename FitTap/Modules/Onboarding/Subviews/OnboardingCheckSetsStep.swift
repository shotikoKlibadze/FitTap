import DesignSystem
import SwiftUI

/// The third onboarding page: the workout card plays itself on a loop — set
/// 1 checked, set 2 checked, set 3 held until its ✓ / ✕ choices open and
/// marked failed — over "Check sets as you go." Watch-only: the card takes
/// no touches.
struct OnboardingCheckSetsStep: View {
    @State private var bench = Self.freshBench
    /// The set whose choices are open in the demo.
    @State private var openSetID: UUID?

    private static let exercise = ExerciseData.exercises.first { $0.name == "Bench Press" }
        ?? Exercise(name: "Bench Press", kind: .weightlifting, loadMode: .perSide, equipment: .barbell, mainMuscleGroup: .chest)

    private static var freshBench: WorkoutExercise {
        WorkoutExercise(
            exerciseID: exercise.id,
            order: 0,
            sets: [
                SetEntry(order: 0, reps: 10, weight: 20),
                SetEntry(order: 1, reps: 10, weight: 20),
                SetEntry(order: 2, reps: 8, weight: 17.5),
            ],
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            ExerciseCard(
                exercise: Self.exercise,
                workoutExercise: $bench,
                mode: .session,
                isScripted: true,
                openChoicesSetID: openSetID,
                onTapReps: { _ in },
                onTapWeight: { _ in },
                onTapSuggestion: {},
                onRemoveExercise: {},
            )
            .allowsHitTesting(false)
            Text("Check sets as you go.")
                .font(FTFonts.title2Bold)
                .foregroundStyle(FTColors.textPrimary)
                .padding(.top, 36)
            Text("Tap the ring when a set is done. Press and hold, and it opens so you can mark the set failed.")
                .font(FTFonts.subheadline)
                .foregroundStyle(FTColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .task { await play() }
    }

    /// The demo, over and over until the page goes away.
    private func play() async {
        do {
            while true {
                try await Task.sleep(for: .seconds(1))
                log(set: 0)
                try await Task.sleep(for: .seconds(0.9))
                log(set: 1)
                try await Task.sleep(for: .seconds(1.1))
                // The hold: the ✓ / ✕ choices grow out of set 3's ring…
                openSetID = bench.sets[2].id
                try await Task.sleep(for: .seconds(1.4))
                // …and ✕ is picked.
                openSetID = nil
                log(set: 2, failed: true)
                try await Task.sleep(for: .seconds(2.4))
                withAnimation(.smooth(duration: 0.4)) { bench = Self.freshBench }
            }
        } catch {
            // Cancelled: the page left.
        }
    }

    private func log(set index: Int, failed: Bool = false) {
        withAnimation(.smooth(duration: 0.2)) {
            bench.sets[index].loggedAt = .now
            bench.sets[index].failed = failed
        }
    }
}

#if DEBUG
private struct OnboardingCheckSetsStepPreviewHost: View {
    var body: some View {
        OnboardingCheckSetsStep()
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FTColors.background)
    }
}

#Preview("Dark") {
    OnboardingCheckSetsStepPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingCheckSetsStepPreviewHost()
        .preferredColorScheme(.light)
}
#endif
