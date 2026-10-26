import DesignSystem
import SwiftUI

/// An exercise inside a workout being built: name header, one row per set
/// (reps pill, weight pill, remove), and "+ Add Set". The card edits the
/// workout exercise's sets through its binding; adding a set repeats the
/// last one, so the common case — identical sets — costs one tap. Cardio has
/// no sets: one row with duration and an optional speed, nothing to add.
struct ExerciseCard: View {
    let exercise: Exercise
    @Binding var workoutExercise: WorkoutExercise
    /// e.g. "Previous best 20 kg /side × 10"; nil hides the line.
    var previousBest: String?
    var unit: WeightUnit = .kg
    /// Reps / weight pill tapped for the set with this id — the parent opens
    /// the matching picker and writes the chosen value back through the binding.
    let onTapReps: (UUID) -> Void
    let onTapWeight: (UUID) -> Void
    /// Cardio duration / speed pill tapped — the parent opens the picker.
    var onTapDuration: () -> Void = {}
    var onTapSpeed: () -> Void = {}
    /// The wand in the header — opens this exercise's suggestion.
    let onTapSuggestion: () -> Void
    /// Fired when the last set is removed — the card has nothing left to show.
    let onRemoveExercise: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            Rectangle()
                .fill(FTColors.divider)
                .frame(height: 1)

            VStack(spacing: 10) {
                if let cardio = workoutExercise.cardio {
                    cardioRow(cardio)
                } else {
                    ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, set in
                        setRow(index: index, set: set)
                    }
                    addSetButton
                }
            }
            .padding(14)
        }
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                if let previousBest {
                    Text(previousBest)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
            Spacer(minLength: 0)
            SuggestionButton(action: onTapSuggestion)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func setRow(index: Int, set: SetEntry) -> some View {
        HStack(spacing: 8) {
            Text("\(index + 1)")
                .font(FTFonts.footnoteSemibold)
                .foregroundStyle(FTColors.textSecondary)
                .frame(width: 22)

            // Reps : weight split 1 : 1.35, as in the design. Fixed shares —
            // a layout priority would let one pill swallow the other.
            GeometryReader { proxy in
                let repsWidth = (proxy.size.width - 8) / 2.35
                HStack(spacing: 8) {
                    pill(value: "\(set.reps)", unitLabel: "reps") {
                        onTapReps(set.id)
                    }
                    .frame(width: repsWidth)

                    pill(value: weightValue(set), unitLabel: weightUnitLabel) {
                        onTapWeight(set.id)
                    }
                }
            }
            .frame(height: 44)

            removeButton { removeSet(set.id) }
        }
    }

    /// Duration and optional speed; no set number. Removing it removes the
    /// exercise, since cardio is one entry.
    private func cardioRow(_ cardio: CardioEntry) -> some View {
        HStack(spacing: 8) {
            pill(value: "\(Int(cardio.duration / 60))", unitLabel: "min", action: onTapDuration)
            pill(value: cardio.speedKmh.map(LoadDisplayFormatter.trimmed) ?? "—", unitLabel: "km/h", action: onTapSpeed)
            removeButton(action: onRemoveExercise)
        }
    }

    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            FTIcons.xMark
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundStyle(FTColors.textSecondary)
                .frame(width: 30, height: 30)
                .background(Circle().fill(FTColors.secondary))
                .contentShape(Circle())
        }
        .buttonStyle(.press)
    }

    private func pill(value: String, unitLabel: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value)
                    .font(FTFonts.bodySemibold)
                    .foregroundStyle(FTColors.textPrimary)
                if let unitLabel {
                    Text(unitLabel)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Capsule().fill(FTColors.secondary))
            .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .frame(maxWidth: .infinity)
    }

    private var addSetButton: some View {
        PillButton(title: "+ Add Set", color: .neutralYellow, size: .compact, action: addSet)
    }

    // MARK: - Display

    /// Bodyweight sets read "BW" / "BW + 10"; weighted sets show the number,
    /// with the unit and per-side/per-hand suffix in the small label.
    private func weightValue(_ set: SetEntry) -> String {
        switch exercise.kind {
        case .bodyweight:
            guard let added = set.weight, added > 0 else { return "BW" }
            return "BW + \(LoadDisplayFormatter.trimmed(added))"
        case .weightlifting, .cardio:
            guard let weight = set.weight else { return "—" }
            return LoadDisplayFormatter.trimmed(weight)
        }
    }

    private var weightUnitLabel: String? {
        switch exercise.loadMode {
        case .perSide: "\(unit.rawValue) /side"
        case .perHand: "\(unit.rawValue) /hand"
        case .machineStack, .total: unit.rawValue
        case nil: exercise.kind == .bodyweight ? nil : unit.rawValue
        }
    }

    // MARK: - Editing

    private func addSet() {
        let last = workoutExercise.sets.last
        let newSet = SetEntry(
            order: workoutExercise.sets.count,
            reps: last?.reps ?? 10,
            weight: last?.weight,
        )
        withAnimation(.smooth(duration: 0.25)) {
            workoutExercise.sets.append(newSet)
        }
    }

    private func removeSet(_ id: UUID) {
        guard workoutExercise.sets.count > 1 else {
            onRemoveExercise()
            return
        }
        withAnimation(.smooth(duration: 0.25)) {
            workoutExercise.sets.removeAll { $0.id == id }
            for index in workoutExercise.sets.indices {
                workoutExercise.sets[index].order = index
            }
        }
    }
}

#if DEBUG
private struct ExerciseCardPreviewHost: View {
    @State private var bench = WorkoutExercise(
        exerciseID: Exercise.sample.id,
        order: 0,
        sets: [
            SetEntry(order: 0, reps: 10, weight: 20),
            SetEntry(order: 1, reps: 10, weight: 20),
            SetEntry(order: 2, reps: 8, weight: 17.5),
        ],
    )
    @State private var running = WorkoutExercise(
        exerciseID: Exercise.sampleCardio.id,
        order: 1,
        cardio: CardioEntry(duration: 30 * 60),
    )
    @State private var removed = false

    var body: some View {
        ScrollView {
            if removed {
                Text("Exercise removed")
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
            } else {
                ExerciseCard(
                    exercise: .sample,
                    workoutExercise: $bench,
                    previousBest: "Previous best 20 kg /side × 10",
                    // Stand-ins for the pickers: each tap bumps the value.
                    onTapReps: { id in
                        guard let index = bench.sets.firstIndex(where: { $0.id == id }) else { return }
                        bench.sets[index].reps += 1
                    },
                    onTapWeight: { id in
                        guard let index = bench.sets.firstIndex(where: { $0.id == id }) else { return }
                        bench.sets[index].weight = (bench.sets[index].weight ?? 0) + 2.5
                    },
                    onTapSuggestion: {},
                    onRemoveExercise: { removed = true },
                )
            }
            ExerciseCard(
                exercise: .sampleCardio,
                workoutExercise: $running,
                onTapReps: { _ in },
                onTapWeight: { _ in },
                onTapSuggestion: {},
                onRemoveExercise: {},
            )
        }
        .contentMargins(16, for: .scrollContent)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    ExerciseCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ExerciseCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
