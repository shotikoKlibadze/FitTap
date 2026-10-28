import DesignSystem
import SwiftUI

struct AddExerciseView: View {
    @Binding var filter: AddExerciseFilter
    let exercises: [Exercise]
    let selectedIDs: Set<UUID>
    let onToggleExercise: (UUID) -> Void
    let onTapCreateExercise: () -> Void
    let onTapAdd: () -> Void

    private var addTitle: String {
        switch selectedIDs.count {
        case 0: "Add Exercises"
        case 1: "Add 1 Exercise · 1 set"
        default: "Add \(selectedIDs.count) Exercises · 1 set each"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "\(exercises.count) Exercises")

                VStack(spacing: 0) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseListItem(
                            exercise: exercise,
                            isSelected: selectedIDs.contains(exercise.id),
                            position: position(index),
                        ) {
                            onToggleExercise(exercise.id)
                        }
                    }
                }
            }
        }
        .contentMargins(.horizontal, 8, for: .scrollContent)
        .scrollIndicators(.hidden)
        // The filter bar floats: the list scrolls under it and fades out
        // through the gradient behind it.
        .safeAreaInset(edge: .top, spacing: 16) {
            filterBar
                .background {
                    // Solid from the screen top to the chips' top edge, then a
                    // fade across the whole 40pt row and 16pt past it, so rows
                    // dissolve as they pass under.
                    VStack(spacing: 0) {
                        FTColors.background
                        FTGradients.fadeTop
                            .frame(height: 40 + 16) // the full chip row + overhang
                    }
                    .padding(.bottom, -16)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                }
        }
        .bottomActionBar {
            GlassPillButton(title: addTitle, disabled: selectedIDs.isEmpty, action: onTapAdd)
        }
        .background(FTColors.background)
    }

    /// The create button stays put; the chips scroll underneath it.
    private var filterBar: some View {
        ZStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Chip(title: "All", isSelected: filter == .all) {
                        filter = .all
                    }
                    // Right after All, so a cardio workout opening on it shows it.
                    Chip(title: "Cardio", isSelected: filter == .cardio) {
                        filter = .cardio
                    }
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        Chip(title: group.displayName, isSelected: filter == .muscle(group)) {
                            filter = .muscle(group)
                        }
                    }
                }
            }
            .contentMargins(.leading, 56, for: .scrollContent)
            .contentMargins(.trailing, 8, for: .scrollContent)

            // Opaque block to the screen edge so chips vanish under the button.
            FTColors.background
                .frame(width: 56)
                .frame(height: 40)

            RoundButton(
                icon: .add,
                style: .normal,
                iconColor: FTColors.yellow,
                backgroundColor: FTColors.surface, // same fill as the chips
                action: onTapCreateExercise,
            )
                .padding(.leading, 8)
        }
    }

    private func position(_ index: Int) -> ExerciseListItem.Position {
        if exercises.count == 1 { return .single }
        if index == 0 { return .first }
        if index == exercises.count - 1 { return .last }
        return .middle
    }
}

#if DEBUG
private struct AddExerciseViewPreviewHost: View {
    @State private var filter = AddExerciseFilter.muscle(.chest)
    @State private var selectedIDs: Set<UUID> = []

    private var exercises: [Exercise] {
        ExerciseData.exercises.sorted { $0.name < $1.name }.filter(filter.includes)
    }

    var body: some View {
        NavigationStack {
            AddExerciseView(
                filter: $filter,
                exercises: exercises,
                selectedIDs: selectedIDs,
                onToggleExercise: { id in
                    if selectedIDs.contains(id) { selectedIDs.remove(id) } else { selectedIDs.insert(id) }
                },
                onTapCreateExercise: {},
                onTapAdd: {},
            )
        }
    }
}
#Preview("Light") {
    AddExerciseViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    AddExerciseViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
