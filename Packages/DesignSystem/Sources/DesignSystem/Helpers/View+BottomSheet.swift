import SwiftUI

public extension View {
    /// Presents a `BottomSheet` while `item` is non-nil, over the whole app —
    /// toolbar and tab bar dimmed too. Set `item` to nil to close it; the
    /// sheet sets it to nil itself on a drag down or a tap on the dim. The
    /// item keeps rendering through the closing slide.
    func bottomSheet<Item: Equatable, SheetContent: View>(
        item: Binding<Item?>,
        height: @escaping (Item) -> CGFloat,
        @ViewBuilder content: @escaping (Item) -> SheetContent,
    ) -> some View {
        modifier(BottomSheetModifier(item: item, height: height, sheetContent: content))
    }

    /// Presents a `BottomSheet` while `isPresented` is true — for sheets
    /// that carry no item of their own.
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        height: CGFloat,
        @ViewBuilder content: @escaping () -> SheetContent,
    ) -> some View {
        bottomSheet(
            item: Binding<Bool?>(
                get: { isPresented.wrappedValue ? true : nil },
                set: { isPresented.wrappedValue = $0 ?? false },
            ),
            height: { _ in height },
            content: { _ in content() },
        )
    }
}

/// Hosts the sheet in a clear full-screen cover so the dim covers the system
/// bars. The cover appears and leaves without animation; the sheet animates
/// itself inside it and reports when it has slid away.
private struct BottomSheetModifier<Item: Equatable, SheetContent: View>: ViewModifier {
    @Binding var item: Item?
    let height: (Item) -> CGFloat
    let sheetContent: (Item) -> SheetContent

    /// The cover on screen and the item it renders — outlives `item` until
    /// the sheet has slid away.
    @State private var cover: BottomSheetCover<Item>?
    /// Read inside the cover through Observation, so the presented content
    /// sees open/close changes however the cover's hosting updates.
    @State private var presentation = BottomSheetPresentation()

    func body(content: Content) -> some View {
        content
            .onChange(of: item, initial: true) { _, newItem in
                presentation.isPresented = newItem != nil
                guard let newItem else { return }
                if cover == nil {
                    withoutAnimation { cover = BottomSheetCover(item: newItem) }
                } else {
                    cover?.item = newItem
                }
            }
            .fullScreenCover(item: $cover) { cover in
                BottomSheet(
                    isPresented: presentation.isPresented,
                    height: height(cover.item),
                    onClose: { item = nil },
                    onDismissed: dismissCover,
                ) {
                    sheetContent(cover.item)
                }
                .presentationBackground(.clear)
            }
    }

    private func dismissCover() {
        guard !presentation.isPresented else { return }
        withoutAnimation { cover = nil }
    }

    private func withoutAnimation(_ change: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, change)
    }
}

private struct BottomSheetCover<Item>: Identifiable {
    let id = UUID()
    var item: Item
}

@MainActor
@Observable
private final class BottomSheetPresentation {
    var isPresented = false
}
