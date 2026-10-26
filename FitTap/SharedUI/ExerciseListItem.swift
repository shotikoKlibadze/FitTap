import DesignSystem
import SwiftUI

/// One row of an exercise list: equipment glyph in a circle, name, equipment
/// label, and a selection ring that fills green when picked. `position`
/// rounds only the outer corners when rows stack into one card.
struct ExerciseListItem: View {
    enum Position {
        case first
        case middle
        case last
        case single

        var topRadius: CGFloat {
            switch self {
            case .first, .single: 24
            case .middle, .last: 0
            }
        }

        var bottomRadius: CGFloat {
            switch self {
            case .last, .single: 24
            case .middle, .first: 0
            }
        }
    }

    let exercise: Exercise
    let isSelected: Bool
    var position: Position = .single
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                exercise.equipment.icon
                    .font(.system(size: 18))
                    .foregroundStyle(FTColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(FTColors.surfaceSecondary))

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(FTFonts.headline)
                        .foregroundStyle(FTColors.textPrimary)
                    Text(exercise.equipment.displayName)
                        .font(FTFonts.footnote)
                        .foregroundStyle(FTColors.textSecondary)
                }

                Spacer()

                selectionIndicator
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: position.topRadius,
                    bottomLeadingRadius: position.bottomRadius,
                    bottomTrailingRadius: position.bottomRadius,
                    topTrailingRadius: position.topRadius,
                    style: .continuous,
                )
                .fill(FTColors.surface)
            )
            .overlay(alignment: .bottom) {
                if position == .first || position == .middle {
                    Rectangle()
                        .fill(FTColors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, 14)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.press)
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        if isSelected {
            Circle()
                .fill(FTColors.greenAccent)
                .frame(width: 26, height: 26)
                .overlay {
                    FTIcons.check
                        .resizable()
                        .scaledToFit()
                        .frame(width: 11, height: 11)
                        .foregroundStyle(FTCoreColors.offWhite)
                }
        } else {
            Circle()
                .stroke(FTColors.separator, lineWidth: 1.5)
                .frame(width: 26, height: 26)
        }
    }
}

#if DEBUG
private struct ExerciseListItemPreviewHost: View {
    @State private var selectedIDs: Set<UUID> = []
    private let exercises = Array(ExerciseData.exercises.prefix(5))

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseListItem(
                        exercise: exercise,
                        isSelected: selectedIDs.contains(exercise.id),
                        position: index == 0 ? .first : (index == exercises.count - 1 ? .last : .middle),
                    ) {
                        if selectedIDs.contains(exercise.id) {
                            selectedIDs.remove(exercise.id)
                        } else {
                            selectedIDs.insert(exercise.id)
                        }
                    }
                }
            }
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    ExerciseListItemPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ExerciseListItemPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
