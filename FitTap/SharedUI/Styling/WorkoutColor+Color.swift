import DesignSystem
import SwiftUI

/// The canonical mapping from semantic workout colors to rendered colors.
/// UI reads colors only through this — never raw literals in feature code.
extension WorkoutColor {
    var color: Color {
        switch self {
        case .red: .red
        case .crimson: Color(red: 0.86, green: 0.08, blue: 0.24)
        case .coral: Color(red: 1.0, green: 0.5, blue: 0.31)
        case .salmon: Color(red: 0.98, green: 0.5, blue: 0.45)
        case .orange: .orange
        case .peach: Color(red: 1.0, green: 0.75, blue: 0.55)
        case .gold: Color(red: 0.95, green: 0.78, blue: 0.2)
        case .yellow: .yellow
        case .lime: Color(red: 0.7, green: 0.9, blue: 0.1)
        case .olive: Color(red: 0.55, green: 0.55, blue: 0.1)
        case .green: .green
        case .emerald: Color(red: 0.31, green: 0.78, blue: 0.47)
        case .forest: Color(red: 0.18, green: 0.55, blue: 0.24)
        case .mint: .mint
        case .teal: .teal
        case .cyan: .cyan
        case .sky: Color(red: 0.45, green: 0.75, blue: 0.95)
        case .blue: .blue
        case .navy: Color(red: 0.15, green: 0.25, blue: 0.6)
        case .indigo: .indigo
        case .lavender: Color(red: 0.71, green: 0.55, blue: 0.9)
        case .purple: .purple
        case .magenta: Color(red: 0.85, green: 0.2, blue: 0.75)
        case .pink: .pink
        case .rose: Color(red: 1.0, green: 0.45, blue: 0.6)
        case .brown: .brown
        case .sand: Color(red: 0.78, green: 0.7, blue: 0.52)
        case .gray: .gray
        }
    }
}

#if DEBUG
private struct WorkoutColorPreviewHost: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(WorkoutColor.allCases, id: \.self) { workoutColor in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(workoutColor.color)
                            .frame(width: 44, height: 44)
                        Text(workoutColor.rawValue)
                            .font(FTFonts.caption2)
                            .foregroundStyle(FTColors.textSecondary)
                    }
                }
            }
            .padding()
        }
        .background(FTColors.background)
    }
}
#Preview("Light") {
    WorkoutColorPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    WorkoutColorPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
