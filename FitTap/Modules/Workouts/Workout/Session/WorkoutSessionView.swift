import DesignSystem
import SwiftUI

/// A workout in progress. The name with a close button and the progress card
/// sit pinned at the top, with nothing behind them — the exercise cards
/// scroll on under them in plain view. "Finish Workout" is pinned at the
/// bottom over its fade.
///
/// The corner ⋯ opens into "Edit" and ✕. "Edit" turns the cards into the
/// workout editor's — pills, a ✕ per set, "+ Add Set" — to swipe away or
/// hold and drag into a new order, with "Add Exercise" below, until "Done".
/// Once a set is logged, the ✕ asks before
/// leaving: it morphs into "End this workout?" at its corner over a dimmed
/// screen. The menu floats in an overlay over a slot in the title row, so it
/// can grow over the title and the progress card.
struct WorkoutSessionView: View {
    let title: String
    /// The workout's color — the background breathes in it.
    let color: Color
    @Binding var isConfirmingExit: Bool
    @Binding var isEditing: Bool
    let hasLoggedSets: Bool
    let exitMessage: String
    let progress: Double
    let progressTitle: String
    let progressSubtitle: String
    let startedAt: Date
    @Binding var exercises: [WorkoutExercise]
    let catalog: [UUID: Exercise]
    /// (workout exercise id, set id)
    let onTapReps: (UUID, UUID) -> Void
    let onTapWeight: (UUID, UUID) -> Void
    /// Cardio duration / speed pill tapped for the workout exercise with this id.
    let onTapDuration: (UUID) -> Void
    let onTapSpeed: (UUID) -> Void
    /// An exercise swiped away (or its last set removed) while editing.
    let onRemoveExercise: (UUID) -> Void
    /// "Add Exercise" under the cards while editing.
    let onTapAddExercise: () -> Void
    /// ✕ with nothing logged — leave without asking.
    let onClose: () -> Void
    /// "End Workout" in the exit confirmation.
    let onEndWorkout: () -> Void
    let onFinish: () -> Void

    /// Rating an exercise moves on: the next one scrolls up to the top,
    /// ready for its first set. The last one stays put.
    private func scrollPast(_ id: UUID, with scroller: ScrollViewProxy) {
        guard let index = exercises.firstIndex(where: { $0.id == id }), index + 1 < exercises.count else { return }
        withAnimation(.smooth(duration: 0.45)) {
            scroller.scrollTo(exercises[index + 1].id, anchor: .top)
        }
    }

    /// The title row's height, so the floating ✕ lines up with its slot.
    private let titleRowHeight: CGFloat = 44
    /// The cards' inset from the screen edge — the summary card uses the
    /// same, so it lines up with the exercise cards.
    private let gutter: CGFloat = 16
    /// The title and the ✕ line up with the cards.
    private let titleInset: CGFloat = 16
    private let closeSize = GlassEditCloseMenu.collapsedSize
    /// Gap between the summary card and the scrolling content.
    private let headerBottomPadding: CGFloat = 12


    /// The summary card's height, so the cards know where its top is.
    @State private var summaryHeight: CGFloat = 0
    /// Bumped when a drag to reorder lifts a card — one tap of haptics.
    @State private var reorderLift = 0
    /// The drag session already announced, so its later updates stay quiet.
    @State private var liftedDrag: DragSession.ID?

    var body: some View {
        ScrollViewReader { scroller in
            ScrollView {
                VStack(spacing: 12) {
                    if isEditing {
                        Text("Swipe to delete · hold to reorder")
                            .font(FTFonts.footnote)
                            .foregroundStyle(FTColors.textSecondary)
                            .transition(.opacity)
                        editList
                        AddButton(title: "Add Exercise", action: onTapAddExercise)
                            .transition(.opacity)
                    } else {
                        sessionList(scroller: scroller)
                    }
                }
                .animation(.smooth(duration: 0.3), value: exercises.map(\.id))
            }
            .contentMargins(.horizontal, gutter, for: .scrollContent)
            // Room to scroll the last card clear of the Finish button.
            .contentMargins(.bottom, 32, for: .scrollContent)
            .scrollIndicators(.hidden)
            // One swipe open at a time while editing, closed by scrolling.
            .swipeActionsContainer()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .bottomActionBar {
            GlassPillButton(title: "Finish Workout", action: onFinish)
        }
        // Dims everything — header and Finish included — behind the open card.
        .overlay {
            if isConfirmingExit {
                FTColors.scrim
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: keepGoing)
                    .transition(.opacity)
            }
        }
        .overlay(alignment: .topTrailing) {
            closeControl
                .padding(.top, 8 + (titleRowHeight - closeSize) / 2)
                .padding(.trailing, titleInset)
        }
        .background { MeshBackground(tint: color) }
    }

    /// The ⋯ menu. Its ✕ leaves at once with nothing logged; with something
    /// logged it opens into the exit confirmation.
    private var closeControl: some View {
        GlassEditCloseMenu(
            isEditing: $isEditing,
            isConfirming: $isConfirmingExit,
            confirmation: hasLoggedSets
                ? .init(
                    title: "End this workout?",
                    message: exitMessage,
                    actions: [
                        AppAlertAction("End Workout", style: .destructive, action: onEndWorkout),
                        AppAlertAction("Keep Going", style: .primary),
                    ],
                )
                : nil,
            onClose: onClose,
        )
    }

    /// Working out: the cards take every tap and hold, nothing reorders.
    private func sessionList(scroller: ScrollViewProxy) -> some View {
        ForEach($exercises) { $workoutExercise in
            if let exercise = catalog[workoutExercise.exerciseID] {
                SessionExerciseCard(
                    exercise: exercise,
                    workoutExercise: $workoutExercise,
                    onTapReps: { setID in onTapReps(workoutExercise.id, setID) },
                    onTapWeight: { setID in onTapWeight(workoutExercise.id, setID) },
                    onTapDuration: { onTapDuration(workoutExercise.id) },
                    onTapSpeed: { onTapSpeed(workoutExercise.id) },
                    onRated: { scrollPast(workoutExercise.id, with: scroller) },
                )
                .id(workoutExercise.id)
                .modifier(StackBehindSummary(summaryTop: summaryTop))
            }
        }
    }

    /// Editing: edit cards to swipe away, or hold and drag to reorder. It's a
    /// separate list because a reorderable card lifts on a long press even
    /// with reordering off, which would steal a set's ✓ hold while working
    /// out. Loops over values, not `ForEach($exercises)`: the reorder
    /// container crashes on a binding loop.
    private var editList: some View {
        VStack(spacing: 12) {
            ForEach(exercises) { workoutExercise in
                if let exercise = catalog[workoutExercise.exerciseID] {
                    // The workout editor's card: pills, a ✕ per set and
                    // "+ Add Set". No checks, so no hold for the drag to fight.
                    ExerciseCard(
                        exercise: exercise,
                        workoutExercise: binding(for: workoutExercise),
                        mode: .edit,
                        onTapReps: { setID in onTapReps(workoutExercise.id, setID) },
                        onTapWeight: { setID in onTapWeight(workoutExercise.id, setID) },
                        onTapDuration: { onTapDuration(workoutExercise.id) },
                        onTapSpeed: { onTapSpeed(workoutExercise.id) },
                        onTapSuggestion: {},
                        onRemoveExercise: { onRemoveExercise(workoutExercise.id) },
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation(.smooth(duration: 0.25)) {
                                onRemoveExercise(workoutExercise.id)
                            }
                        } label: {
                            Label { Text("Delete") } icon: { FTIcons.trash }
                                // Just the icon; "Delete" stays for VoiceOver.
                                .labelStyle(.iconOnly)
                        }
                    }
                    // The reorder container needs each row's id.
                    .id(workoutExercise.id)
                    .modifier(StackBehindSummary(summaryTop: summaryTop))
                }
            }
            .reorderable()
        }
        .reorderContainer(for: WorkoutExercise.self, isEnabled: true) { difference in
            withAnimation(.smooth(duration: 0.3)) {
                exercises.reorder(difference)
            }
        }
        // A light thud as the card lifts and reordering starts.
        .onDragSessionUpdated { session in
            guard session.id != liftedDrag else { return }
            liftedDrag = session.id
            reorderLift += 1
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: reorderLift)
    }

    /// A binding to one exercise, looked up by id.
    private func binding(for exercise: WorkoutExercise) -> Binding<WorkoutExercise> {
        Binding(
            get: { exercises.first { $0.id == exercise.id } ?? exercise },
            set: { updated in
                guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
                exercises[index] = updated
            },
        )
    }

    private func keepGoing() {
        withAnimation(.smooth(duration: 0.3)) { isConfirmingExit = false }
    }

    /// How far above the scroll area's top the summary card's top sits.
    private var summaryTop: CGFloat {
        summaryHeight + headerBottomPadding
    }

    /// Pinned over the cards, with no background of its own.
    private var header: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Text(title)
                    .font(FTFonts.largeTitleBold)
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                // Holds the ✕'s place; the ✕ itself floats in an overlay.
                Color.clear
                    .frame(width: closeSize, height: closeSize)
            }
            .frame(height: titleRowHeight)
            // On top of the header's gutter, to reach the title inset.
            .padding(.horizontal, titleInset - gutter)
            WorkoutProgressCard(
                progress: progress,
                title: progressTitle,
                subtitle: progressSubtitle,
                startedAt: startedAt,
            )
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { summaryHeight = $0 }
        }
        .padding(.horizontal, gutter)
        .padding(.top, 8)
        .padding(.bottom, headerBottomPadding)
    }
}

#if DEBUG
private struct WorkoutSessionViewPreviewHost: View {
    @State private var exercises: [WorkoutExercise] = {
        var exercises = WorkoutData.templates[0].exercises
        // Two sets of the first exercise already logged.
        exercises[0].sets[0].loggedAt = .now
        exercises[0].sets[1].loggedAt = .now
        return exercises
    }()
    @State private var isConfirmingExit = false
    @State private var isEditing = false

    private let catalog = Dictionary(uniqueKeysWithValues: ExerciseData.exercises.map { ($0.id, $0) })

    private var setCount: Int { exercises.reduce(0) { $0 + $1.sets.count } }
    private var loggedCount: Int { exercises.reduce(0) { $0 + $1.sets.filter { $0.loggedAt != nil }.count } }

    var body: some View {
        WorkoutSessionView(
            title: "Push Day",
            color: .pink,
            isConfirmingExit: $isConfirmingExit,
            isEditing: $isEditing,
            hasLoggedSets: loggedCount > 0,
            exitMessage: "You've logged \(loggedCount) of \(setCount) sets. Unfinished workouts aren't saved.",
            progress: Double(loggedCount) / Double(max(setCount, 1)),
            progressTitle: "\(loggedCount) of \(setCount) sets",
            progressSubtitle: "\(exercises.filter { $0.sets.contains { $0.loggedAt == nil } }.count) exercises left",
            startedAt: .now.addingTimeInterval(-(18 * 60 + 42)),
            exercises: $exercises,
            catalog: catalog,
            onTapReps: { _, _ in },
            onTapWeight: { _, _ in },
            onTapDuration: { _ in },
            onTapSpeed: { _ in },
            onRemoveExercise: { id in exercises.removeAll { $0.id == id } },
            onTapAddExercise: {},
            onClose: {},
            onEndWorkout: {},
            onFinish: {},
        )
    }
}

#Preview("Dark") {
    WorkoutSessionViewPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    WorkoutSessionViewPreviewHost()
        .preferredColorScheme(.light)
}
#endif
