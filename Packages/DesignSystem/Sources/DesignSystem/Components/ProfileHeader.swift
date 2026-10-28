import SwiftUI

/// The user at the top of Home: a round avatar beside a title and a line
/// of secondary text. Without a photo the avatar shows the title's first
/// letter.
public struct ProfileHeader: View {
    let image: Image?
    let title: String
    let subtitle: String

    public init(image: Image?, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }

    private let avatarSize: CGFloat = 52

    public var body: some View {
        HStack(spacing: 13) {
            avatar
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .elevatedSurface(in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FTFonts.title2Bold)
                    .foregroundStyle(FTColors.textPrimary)
                Text(subtitle)
                    .font(FTFonts.subheadline)
                    .foregroundStyle(FTColors.textSecondary)
                    .monospacedDigit()
            }
            .lineLimit(1)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let image {
            image
                .resizable()
                .scaledToFill()
        } else {
            Text(title.prefix(1).uppercased())
                .font(FTFonts.title3Semibold)
                .foregroundStyle(FTColors.textPrimary)
        }
    }
}

#if DEBUG
private struct ProfileHeaderPreviewHost: View {
    @State private var showsPhoto = false

    var body: some View {
        VStack(spacing: 24) {
            ProfileHeader(
                image: showsPhoto ? Image(systemName: "person.crop.circle.fill") : nil,
                title: "Dan, 27",
                subtitle: "78.4 kg · down 0.6 this month",
            )
            Toggle("Photo", isOn: $showsPhoto)
                .font(FTFonts.body)
                .foregroundStyle(FTColors.textPrimary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColors.background)
    }
}

#Preview("Light") {
    ProfileHeaderPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ProfileHeaderPreviewHost()
        .preferredColorScheme(.dark)
}
#endif
