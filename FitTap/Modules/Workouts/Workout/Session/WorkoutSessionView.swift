import DesignSystem
import SwiftUI

/// A workout in progress. The name with a close button and the progress card
/// sit pinned at the top, with nothing behind them — the exercise cards
/// scroll on under them in plain view. "Finish Workout" is pinned at the
/// bottom over its fade.
///
/// Once a set is logged, the ✕ asks before leaving: it morphs into "End this
/// workout?" at its corner over a dimmed screen. It floats in an overlay over
/// a slot in the title row, so the card can grow over the progress card.
struct WorkoutSessionView: View {
    let title: String
    /// The workout's color — the background breathes in it.
    let color: Color
    @Binding var isConfirmingExit: Bool
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

    /// A binding to one exercise, looked up by id. The list loops over the
    /// exercises as values, not `ForEach($exercises)`: the reorder container
    /// crashes on a binding loop ("Unexpected identifier type").
    private func binding(for exercise: WorkoutExercise) -> Binding<WorkoutExercise> {
        Binding(
            get: { exercises.first { $0.id == exercise.id } ?? exercise },
            set: { updated in
                guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
                exercises[index] = updated
            },
        )
    }

    /// The title row's height, so the floating ✕ lines up with its slot.
    private let titleRowHeight: CGFloat = 44
    /// The cards' inset from the screen edge — the summary card uses the
    /// same, so it lines up with the exercise cards.
    private let gutter: CGFloat = 16
    /// The title and the ✕ line up with the cards.
    private let titleInset: CGFloat = 16
    private let closeSize = GlassCloseConfirmation.collapsedSize
    /// Gap between the summary card and the scrolling content.
    private let headerBottomPadding: CGFloat = 12

    /// Bumped when a drag to reorder lifts a card — one tap of haptics.
    @State private var reorderLift = 0
    /// The drag session already announced, so its later updates stay quiet.
    @State private var liftedDrag: DragSession.ID?

    /// The summary card's height, so the cards know where its top is.
    @State private var summaryHeight: CGFloat = 0

    var body: some View {
        ScrollViewReader { scroller in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(exercises) { workoutExercise in
                        if let exercise = catalog[workoutExercise.exerciseID] {
                            SessionExerciseCard(
                                exercise: exercise,
                                workoutExercise: binding(for: workoutExercise),
                                onTapReps: { setID in onTapReps(workoutExercise.id, setID) },
                                onTapWeight: { setID in onTapWeight(workoutExercise.id, setID) },
                                onTapDuration: { onTapDuration(workoutExercise.id) },
                                onTapSpeed: { onTapSpeed(workoutExercise.id) },
                                onRated: { scrollPast(workoutExercise.id, with: scroller) },
                            )
                            .id(workoutExercise.id)
                            // A card scrolls under the summary untouched; once its
                            // top reaches the summary's top it holds there,
                            // shrinks, blurs and fades — the cards stack away
                            // behind the summary instead of scrolling on past it.
                            // The scroll space starts at the header's bottom, so
                            // the summary's top is `summaryTop` above zero.
                            .visualEffect { [summaryTop] content, proxy in
                                let distance = min(0, proxy.frame(in: .scrollView(axis: .vertical)).minY + summaryTop)
                                return content
                                    .scaleEffect(1 + distance / 700)
                                    .offset(y: -distance / 1.25)
                                    .blur(radius: -distance / 50)
                                    .opacity(1 + distance / 140)
                            }
                        }
                    }
                    // Hold an exercise and drag it to change the order mid-workout.
                    .reorderable()
                }
                .reorderContainer(for: WorkoutExercise.self) { difference in
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
            .contentMargins(.horizontal, gutter, for: .scrollContent)
            // Room to scroll the last card clear of the Finish button.
            .contentMargins(.bottom, 32, for: .scrollContent)
            .scrollIndicators(.hidden)
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

    /// Nothing logged: a plain ✕ that leaves. Something logged: the ✕ that
    /// opens into the exit confirmation. Both are the same glass circle.
    @ViewBuilder
    private var closeControl: some View {
        if hasLoggedSets {
            GlassCloseConfirmation(
                isExpanded: $isConfirmingExit,
                title: "End this workout?",
                message: exitMessage,
                actions: [
                    AppAlertAction("End Workout", style: .destructive, action: onEndWorkout),
                    AppAlertAction("Keep Going", style: .primary),
                ],
            )
        } else {
            RoundButton(icon: .close, action: onClose)
        }
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

    private let catalog = Dictionary(uniqueKeysWithValues: ExerciseData.exercises.map { ($0.id, $0) })

    private var setCount: Int { exercises.reduce(0) { $0 + $1.sets.count } }
    private var loggedCount: Int { exercises.reduce(0) { $0 + $1.sets.filter { $0.loggedAt != nil }.count } }

    var body: some View {
        WorkoutSessionView(
            title: "Push Day",
            color: .pink,
            isConfirmingExit: $isConfirmingExit,
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
