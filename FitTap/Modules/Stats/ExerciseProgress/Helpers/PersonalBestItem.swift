import Foundation

/// An exercise's best set ever, ready for `PersonalBestCard`: the number
/// ("22.5 kg × 6", "BW × 12", "1:30 min"), how the weight is meant ("per
/// side", "per hand", or nothing), and the day it was set ("Aug 24").
struct PersonalBestItem: Hashable {
    let value: String
    let unit: String?
    let date: String
}

#if DEBUG
extension PersonalBestItem {
    static let sample = PersonalBestItem(value: "27.5 kg × 6", unit: "per side", date: "Aug 14")
}
#endif
