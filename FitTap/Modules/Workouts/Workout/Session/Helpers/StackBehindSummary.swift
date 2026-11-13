import SwiftUI

/// A session card scrolls under the summary untouched; once its top reaches
/// the summary's top it holds there, shrinks, blurs and fades — the cards
/// stack away behind the summary instead of scrolling on past it. The scroll
/// space starts at the header's bottom, so the summary's top is `summaryTop`
/// above zero.
struct StackBehindSummary: ViewModifier {
    let summaryTop: CGFloat

    func body(content: Content) -> some View {
        content.visualEffect { [summaryTop] content, proxy in
            let distance = min(0, proxy.frame(in: .scrollView(axis: .vertical)).minY + summaryTop)
            return content
                .scaleEffect(1 + distance / 700)
                .offset(y: -distance / 1.25)
                .blur(radius: -distance / 50)
                .opacity(1 + distance / 140)
        }
    }
}
