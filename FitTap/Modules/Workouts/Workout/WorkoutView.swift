import DesignSystem
import SwiftUI

/// One workout, read or edited — the same screen, so switching morphs it in
/// place instead of pushing a new one:
///
/// - the title row becomes the name field (the color dot stays on the right),
/// - the stats strip becomes the type toggle,
/// - the exercise cards switch to their editing mode,
/// - the subtitle and "Last done" fade out; the section headers, muscle
///   cards and add cards fade in,
/// - the bottom button turns from "Start Workout" into save, and "Plan"
///   beside it (when shown) fades out.
///
/// Flip `isEditing` inside `withAnimation` for the morph.
///
/// "Plan" is a `GlassExpander`: tapped, the pill grows from its corner into
/// the Plan card over a dimmed screen. It floats in an overlay of the bottom
/// bar over a slot of its own width, so nothing in the bar moves.
struct WorkoutView: View {
    let isEditing: Bool
    /// "Plan" beside "Start Workout" while reading.
    let showsPlanButton: Bool
    @Binding var isPlanning: Bool
    @Binding var planDate: Date?
    let planTitle: String
    let today: Date
    let calendar: Calendar
    @Binding var name: String
    @Binding var type: WorkoutType
    @Binding var color: WorkoutColor
    @Binding var primaryMuscleGroup: MuscleGroup?
    @Binding var secondaryMuscleGroup: MuscleGroup?
    @Binding var exercises: [WorkoutExercise]
    let catalog: [UUID: Exercise]
    let subtitle: String
    let stats: [StatsStrip.Stat]
    let lastDoneText: String?
    let saveTitle: String
    let canSave: Bool
    let onTapAddExercise: () -> Void
    /// (workout exercise id, set id)
    let onTapReps: (UUID, UUID) -> Void
    let onTapWeight: (UUID, UUID) -> Void
    /// Cardio duration / speed pill tapped for the workout exercise with this id.
    let onTapDuration: (UUID) -> Void
    let onTapSpeed: (UUID) -> Void
    let onRemoveExercise: (UUID) -> Void
    let onTapSave: () -> Void
    let onTapStart: () -> Void
    let onSavePlan: () -> Void

    /// Pairs the read-only pieces with the controls they become.
    @Namespace private var morph

    private enum MorphID {
        case name
        case typeBar
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                nameSection
                    .zIndex(2) // open color palette floats over the sections below

                typeSection

                if isEditing {
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
                    .transition(.opacity)
                }

                exercisesSection

                if !isEditing, let lastDoneText {
                    Text(lastDoneText)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                        .transition(.opacity)
                }
            }
            .animation(.smooth(duration: 0.3), value: exercises.map(\.id))
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
        // Room to scroll the last card clear of the bottom button and its fade.
        .contentMargins(.bottom, 32, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        // Dims the screen behind the open Plan card; a tap closes it.
        .overlay {
            if isPlanning {
                FTColors.scrim
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: closePlan)
                    .transition(.opacity)
            }
        }
        .bottomActionBar {
            HStack(spacing: 10) {
                if hasPlanSlot {
                    // Holds Plan's place; the pill itself floats in the overlay.
                    Color.clear
                        .frame(width: planButtonWidth, height: PillButtonSize.regular.height)
                }
                // Start is the one live button: a moving red mesh. Saving is
                // plain glass; the two crossfade when the mode flips.
                ZStack {
                    if isEditing {
                        GlassPillButton(title: saveTitle, disabled: !canSave, action: onTapSave)
                            .transition(.opacity)
                    } else {
                        MeshPillButton(title: "Start Workout", tint: color.color, action: onTapStart)
                            .transition(.opacity)
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                if hasPlanSlot {
                    GlassExpander(title: "Plan", isExpanded: $isPlanning, collapsedWidth: planButtonWidth) {
                        PlanWorkoutCard(
                            title: planTitle,
                            date: $planDate,
                            today: today,
                            calendar: calendar,
                            onSave: savePlan,
                            onCancel: closePlan,
                        )
                    }
                    .transition(.opacity)
                }
            }
        }
        .background(FTColors.background)
    }

    /// About a third of the row, as in the design.
    private let planButtonWidth: CGFloat = 112

    private var hasPlanSlot: Bool {
        showsPlanButton && !isEditing
    }

    private func closePlan() {
        withAnimation(.smooth(duration: 0.35)) { isPlanning = false }
    }

    private func savePlan() {
        withAnimation(.smooth(duration: 0.35)) { onSavePlan() }
    }

    // MARK: - Sections

    /// Reading: the name as a heading over its subtitle. Editing: a "Workout
    /// Name" header over the name field. Heading and field morph into each
    /// other; the header and subtitle fade.
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: isEditing ? 16 : 4) {
            if isEditing {
                SectionHeader(title: "Workout Name")
                    .transition(.opacity)
            }
            ZStack {
                if isEditing {
                    WorkoutNameField(name: $name, color: $color)
                        .matchedGeometryEffect(id: MorphID.name, in: morph)
                        .transition(.opacity)
                } else {
                    WorkoutTitleRow(name: name, color: color)
                        .matchedGeometryEffect(id: MorphID.name, in: morph)
                        .transition(.opacity)
                }
            }
            if !isEditing {
                Text(subtitle)
                    .font(FTFonts.subheadline)
                    .foregroundStyle(FTColors.textSecondary)
                    .transition(.opacity)
            }
        }
    }

    /// Reading: the stats strip. Editing: a "Type" header over the type
    /// toggle. Strip and toggle morph into each other.
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                SectionHeader(title: "Type")
                    .transition(.opacity)
            }
            ZStack {
                if isEditing {
                    SegmentedToggle(
                        options: ["Strength", "Cardio"],
                        selectedIndex: Binding(
                            get: { type == .strength ? 0 : 1 },
                            set: { type = $0 == 0 ? .strength : .cardio },
                        ),
                    )
                    .matchedGeometryEffect(id: MorphID.typeBar, in: morph)
                    .transition(.opacity)
                } else {
                    StatsStrip(stats: stats)
                        .matchedGeometryEffect(id: MorphID.typeBar, in: morph)
                        .transition(.opacity)
                }
            }
        }
    }

    @ViewBuilder
    private var exercisesSection: some View {
        if exercises.isEmpty {
            if isEditing {
                CardAddButton(
                    title: "Add Exercise",
                    subtitle: "Add your first exercise to start building the workout.",
                    action: onTapAddExercise,
                )
                .transition(.opacity)
            }
        } else {
            section("Exercises") {
                VStack(spacing: 12) {
                    ForEach($exercises) { $workoutExercise in
                        if let exercise = catalog[workoutExercise.exerciseID] {
                            ExerciseCard(
                                exercise: exercise,
                                workoutExercise: $workoutExercise,
                                mode: isEditing ? .edit : .view,
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
                    if isEditing {
                        CardAddButton(title: "Add Exercise", action: onTapAddExercise)
                            .transition(.opacity)
                    }
                }
            }
        }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: title)
            content()
        }
    }
}

#if DEBUG
private struct WorkoutViewPreviewHost: View {
    private static let pushDay = WorkoutData.templates[0]

    /// 0 = reading, 1 = editing. The toggle animates its change, so flipping
    /// it shows the screen morphing.
    @State private var modeIndex = 0
    @State private var name = pushDay.name
    @State private var type = pushDay.type
    @State private var color = pushDay.color
    @State private var primary = pushDay.primaryMuscleGroup
    @State private var secondary = pushDay.secondaryMuscleGroup
    @State private var exercises = pushDay.exercises
    @State private var isPlanning = false
    @State private var planDate: Date? = .now

    private let catalog = Dictionary(uniqueKeysWithValues: ExerciseData.exercises.map { ($0.id, $0) })

    var body: some View {
        NavigationStack {
            WorkoutView(
                isEditing: modeIndex == 1,
                showsPlanButton: true,
                isPlanning: $isPlanning,
                planDate: $planDate,
                planTitle: "Plan \(name)",
                today: .now,
                calendar: WeekCalendar.calendar,
                name: $name,
                type: $type,
                color: $color,
                primaryMuscleGroup: $primary,
                secondaryMuscleGroup: $secondary,
                exercises: $exercises,
                catalog: catalog,
                subtitle: "Strength · Chest, Shoulders",
                stats: [
                    StatsStrip.Stat(value: "\(exercises.count)", label: "exercises"),
                    StatsStrip.Stat(value: "18", label: "sets"),
                    StatsStrip.Stat(value: "~55", label: "minutes"),
                ],
                lastDoneText: "Last done Monday, Oct 26",
                saveTitle: "Save workout",
                canSave: !exercises.isEmpty,
                onTapAddExercise: addNextExercise,
                onTapReps: { _, _ in },
                onTapWeight: { _, _ in },
                onTapDuration: { _ in },
                onTapSpeed: { _ in },
                onRemoveExercise: { id in exercises.removeAll { $0.id == id } },
                onTapSave: { modeIndex = 0 },
                onTapStart: {},
                onSavePlan: { isPlanning = false },
            )
            .safeAreaInset(edge: .top) {
                SegmentedToggle(options: ["View", "Edit"], selectedIndex: $modeIndex)
                    .padding(.horizontal, 16)
            }
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
    WorkoutViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
