import Foundation

/// Who is training: what Home greets them with. Everything but the name is
/// optional — the app never insists on a body-weight log.
struct UserProfile: Hashable, Codable, Sendable {
    var name: String
    var age: Int?
    var weightKg: Double?
    /// Change over the last month; negative means the user lost weight.
    var weightChangeKgThisMonth: Double?
}
