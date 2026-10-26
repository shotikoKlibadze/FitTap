import DesignSystem
import SwiftUI

/// Bottom-sheet form for an exercise the catalog doesn't have: name, primary
/// and optional secondary muscle, the gear it's done with, then Create & Add.
struct NewExerciseView: View {
    @Binding var name: String
    @Binding var primaryMuscleGroup: MuscleGroup?
    @Binding var secondaryMuscleGroup: MuscleGroup?
    @Binding var equipment: Equipment?
    let primaryOptions: [MuscleGroup]
    let secondaryOptions: [MuscleGroup]
    let equipmentOptions: [Equipment]
    let canCreate: Bool
    let onTapCreate: () -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: NewExerciseMetrics.gridSpacing),
        count: NewExerciseMetrics.gridColumns,
    )

    var body: some View {
        VStack(alignment: .leading, spacing: NewExerciseMetrics.sectionSpacing) {
            Text("New Exercise")
                .font(FTFonts.title3Semibold)
                .foregroundStyle(FTColors.textPrimary)
                .frame(height: NewExerciseMetrics.headerHeight)

            NameTextField(placeholder: "Exercise name", text: $name)

            HStack(spacing: 8) {
                ChipPicker(
                    placeholder: "Primary Muscle",
                    options: primaryOptions,
                    selection: $primaryMuscleGroup,
                    title: \.displayName,
                )
                ChipPicker(
                    placeholder: "Secondary Muscle",
                    options: secondaryOptions,
                    selection: $secondaryMuscleGroup,
                    title: \.displayName,
                )
            }
            .zIndex(1) // an open picker floats over the grid and the button

            LazyVGrid(columns: columns, spacing: NewExerciseMetrics.gridSpacing) {
                ForEach(equipmentOptions, id: \.self) { option in
                    TileButton(
                        icon: option.icon,
                        title: option.displayName,
                        isSelected: option == equipment,
                    ) {
                        withAnimation(.smooth(duration: 0.2)) { equipment = option }
                    }
                }
            }

            Spacer(minLength: 0)

            PillButton(title: "Create & Add", disabled: !canCreate, action: onTapCreate)
        }
        .frame(height: NewExerciseMetrics.contentHeight, alignment: .top)
        .padding(.horizontal, NewExerciseMetrics.horizontalPadding)
        .padding(.bottom, NewExerciseMetrics.bottomPadding)
    }
}

#if DEBUG
private struct NewExerciseViewPreviewHost: View {
    @State private var name = ""
    @State private var primary: MuscleGroup? = .chest
    @State private var secondary: MuscleGroup?
    @State private var equipment: Equipment?

    var body: some View {
        NewExerciseView(
            name: $name,
            primaryMuscleGroup: $primary,
            secondaryMuscleGroup: $secondary,
            equipment: $equipment,
            primaryOptions: MuscleGroup.allCases,
            secondaryOptions: MuscleGroup.allCases.filter { $0 != primary },
            equipmentOptions: [.barbell, .dumbbell, .cable, .machine, .kettlebell, .bodyweight, .pullUpBar, .other],
            canCreate: !name.isEmpty && primary != nil && equipment != nil,
            onTapCreate: {},
        )
        .padding(.top, BottomSheetMetrics.dragAreaHeight)
        .background(FTColors.surface)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    NewExerciseViewPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    NewExerciseViewPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
