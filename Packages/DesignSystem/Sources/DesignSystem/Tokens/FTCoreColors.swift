import SwiftUI

/// Core color tokens — fixed values that never change with light or dark
/// mode. The semantic `FTColors` are built from them. Feature code uses
/// `FTColors`; a core color is for the rare spot that must not adapt, like
/// text on a fill that stays the same color in both modes.
public enum FTCoreColors {
    /// Softened off-white — pure white is too harsh. rgb(224, 224, 224).
    public static let offWhite = Color(white: 0.88)
    /// Near-black. rgb(31, 31, 31).
    public static let nearBlack = Color(white: 0.12)
    /// Metallic AI gold — the same in both modes. rgb(212, 175, 55), #D4AF37.
    public static let aiGold = Color(red: 212 / 255, green: 175 / 255, blue: 55 / 255)
}

#if DEBUG
private struct FTCoreColorsPreviewHost: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            swatch("offWhite", FTCoreColors.offWhite)
            swatch("nearBlack", FTCoreColors.nearBlack)
            swatch("aiGold", FTCoreColors.aiGold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }

    private func swatch(_ name: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .stroke(FTColors.separator, lineWidth: 1)
                .frame(width: 56, height: 36)
            Text(name)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textPrimary)
        }
    }
}

#Preview("Light") {
    FTCoreColorsPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    FTCoreColorsPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
