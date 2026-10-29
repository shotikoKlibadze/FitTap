import DesignSystem
import SwiftUI

/// An exercise inside a workout: name header, then one row per set.
///
/// In `.edit` each row is a reps pill, a weight pill and a remove button,
/// with "+ Add Set" below; the card edits the sets through its binding, and
/// adding a set repeats the last one, so identical sets cost one tap. In
/// `.view` the same rows read as plain text — reps on the left, weight on
/// the right — with nothing to tap but the suggestion wand. In `.session`,
/// while working out, the pills stay so a set's values can still be
/// adjusted, each row ends in a check instead of a remove button, there's no
/// "+ Add Set", and a checked set's values dim. Switching mode inside
/// `withAnimation` morphs the card in place: pills fade to text, the row's
/// trailing button swaps, "+ Add Set" fades, the rows tighten or loosen.
///
/// Cardio has no sets: one row with duration and an optional speed.
struct ExerciseCard: View {
    enum Mode {
        /// Read-only, as on a workout's details.
        case view
        /// Pills to pick values, remove buttons, "+ Add Set".
        case edit
        /// Working out: pills to adjust, a check per set to log it.
        case session
    }

    let exercise: Exercise
    @Binding var workoutExercise: WorkoutExercise
    var mode: Mode = .edit
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

    /// Working out, checking a set sends a ripple across the card from its
    /// check. The origin is read from the check's frame in the card's space;
    /// the count restarts the ripple.
    @State private var checkFrames: [UUID: CGRect] = [:]
    @State private var rippleOrigin = CGPoint.zero
    @State private var rippleCount = 0

    private static let cardSpace = "exerciseCard"

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
                    if isEditing {
                        addSetButton
                            .transition(.opacity)
                    }
                }
            }
            .padding(14)
        }
        .elevatedSurface(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .coordinateSpace(.named(Self.cardSpace))
        .rippleEffect(at: rippleOrigin, trigger: rippleCount)
    }

    private var isEditing: Bool { mode == .edit }

    /// Editing and working out both tap values to change them.
    private var showsPills: Bool { mode != .view }

    /// Pills need room for a thumb; plain text rows sit closer together.
    private var rowHeight: CGFloat { showsPills ? 44 : 28 }

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
        // A logged set steps back while working out; the next one stands out.
        let isDone = mode == .session && set.loggedAt != nil
        return HStack(spacing: 8) {
            Text("\(index + 1)")
                .font(FTFonts.footnoteSemibold)
                .foregroundStyle(FTColors.textSecondary)
                .frame(width: 22)

            // Reps : weight split 1 : 1.35, as in the design. Fixed shares —
            // a layout priority would let one pill swallow the other.
            GeometryReader { proxy in
                let repsWidth = (proxy.size.width - 8) / 2.35
                HStack(spacing: 8) {
                    pill(value: "\(set.reps)", unitLabel: "reps", textAlignment: .leading, isDimmed: isDone) {
                        onTapReps(set.id)
                    }
                    .frame(width: repsWidth)

                    pill(value: weightValue(set), unitLabel: weightUnitLabel, textAlignment: .trailing, isDimmed: isDone) {
                        onTapWeight(set.id)
                    }
                }
            }
            .frame(height: rowHeight)

            switch mode {
            case .edit:
                removeButton { removeSet(set.id) }
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            case .session:
                CheckmarkButton(isChecked: set.loggedAt != nil) { toggleLogged(set.id) }
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(Self.cardSpace)) } action: {
                        checkFrames[set.id] = $0
                    }
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            case .view:
                EmptyView()
            }
        }
    }

    /// Duration and optional speed; no set number. Removing it removes the
    /// exercise, since cardio is one entry.
    private func cardioRow(_ cardio: CardioEntry) -> some View {
        HStack(spacing: 8) {
            pill(value: "\(Int(cardio.duration / 60))", unitLabel: "min", textAlignment: .leading, action: onTapDuration)
            pill(
                value: cardio.speedKmh.map(LoadDisplayFormatter.trimmed) ?? "—",
                unitLabel: "km/h",
                textAlignment: .trailing,
                action: onTapSpeed,
            )
            if isEditing {
                removeButton(action: onRemoveExercise)
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
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

    /// A value with its unit. Editing or working out, it's a centered tappable
    /// pill; viewing, the pill's fill fades away and the text slides to
    /// `textAlignment`, so the same view carries both looks and the switch
    /// animates. `isDimmed` greys the value — a set already logged.
    private func pill(
        value: String,
        unitLabel: String?,
        textAlignment: Alignment,
        isDimmed: Bool = false,
        action: @escaping () -> Void,
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(value)
                    .font(FTFonts.bodySemibold)
                    .foregroundStyle(isDimmed ? FTColors.textSecondary : FTColors.textPrimary)
                if let unitLabel {
                    Text(unitLabel)
                        .font(showsPills ? FTFonts.footnote : FTFonts.bodySemibold)
                        .foregroundStyle(showsPills ? FTColors.textSecondary : FTColors.textPrimary)
                }
            }
            .frame(maxWidth: .infinity, alignment: showsPills ? .center : textAlignment)
            .frame(height: rowHeight)
            .background(Capsule().fill(FTColors.secondary).opacity(showsPills ? 1 : 0))
            .contentShape(Capsule())
        }
        .buttonStyle(.press)
        .allowsHitTesting(showsPills)
        .frame(maxWidth: .infinity)
    }

    private var addSetButton: some View {
        PillButton(title: "+ Add Set", style: .add, size: .compact, action: addSet)
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

    // MARK: - Working out

    /// Logs the set now — with a ripple out from its check — or takes the
    /// log back, quietly.
    private func toggleLogged(_ id: UUID) {
        guard let index = workoutExercise.sets.firstIndex(where: { $0.id == id }) else { return }
        let logging = workoutExercise.sets[index].loggedAt == nil
        withAnimation(.smooth(duration: 0.2)) {
            workoutExercise.sets[index].loggedAt = logging ? .now : nil
        }
        guard logging, let frame = checkFrames[id] else { return }
        rippleOrigin = CGPoint(x: frame.midX, y: frame.midY)
        rippleCount += 1
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
    /// 0 = View, 1 = Edit, 2 = Session. The toggle animates its change, so
    /// flipping it shows the card morphing between modes.
    @State private var modeIndex = 0

    private var mode: ExerciseCard.Mode {
        switch modeIndex {
        case 0: .view
        case 1: .edit
        default: .session
        }
    }

    var body: some View {
        ScrollView {
            SegmentedToggle(options: ["View", "Edit", "Session"], selectedIndex: $modeIndex)
                .padding(.bottom, 16)
            if removed {
                Text("Exercise removed")
                    .font(FTFonts.body)
                    .foregroundStyle(FTColors.textSecondary)
            } else {
                ExerciseCard(
                    exercise: .sample,
                    workoutExercise: $bench,
                    mode: mode,
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
                mode: mode,
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
