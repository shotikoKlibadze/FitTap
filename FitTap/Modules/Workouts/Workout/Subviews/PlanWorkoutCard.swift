import DesignSystem
import SwiftUI

/// What the Plan pill opens into: "Plan Push Day / Pick a day.", a month to
/// pick the day from, then Save and Cancel.
struct PlanWorkoutCard: View {
    let title: String
    @Binding var date: Date?
    let today: Date
    let calendar: Calendar
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(FTFonts.title3Semibold)
                    .foregroundStyle(FTColors.textPrimary)
                    .lineLimit(1)
                Text("Pick a day.")
                    .font(FTFonts.subheadline)
                    .foregroundStyle(FTColors.textSecondary)
            }
            MonthCalendar(selection: $date, today: today, calendar: calendar)
            VStack(spacing: 10) {
                PillButton(title: "Save", disabled: date == nil, action: onSave)
                PillButton(title: "Cancel", style: .secondary, action: onCancel)
            }
        }
    }
}

#if DEBUG
private struct PlanWorkoutCardPreviewHost: View {
    @State private var date: Date? = .now
    @State private var last = "—"

    var body: some View {
        VStack(spacing: 16) {
            PlanWorkoutCard(
                title: "Plan Push Day",
                date: $date,
                today: .now,
                calendar: WeekCalendar.calendar,
                onSave: { last = "saved \(date?.formatted(date: .abbreviated, time: .omitted) ?? "—")" },
                onCancel: { last = "cancelled" },
            )
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(FTColors.surface))
            Text(last)
                .font(FTFonts.footnote)
                .foregroundStyle(FTColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    PlanWorkoutCardPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    PlanWorkoutCardPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
