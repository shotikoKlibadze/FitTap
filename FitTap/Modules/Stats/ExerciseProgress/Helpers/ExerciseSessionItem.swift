import Foundation

/// One row of an exercise's recent sessions, ready for `ProgressionListItem`:
/// the day, the top set's weight ("20 kg /side", "BW", "1 min"), its sets
/// and reps ("4×8"), and whether a set failed.
struct ExerciseSessionItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let value: String
    let sets: String
    let failed: Bool
}

#if DEBUG
extension ExerciseSessionItem {
    static let samples: [ExerciseSessionItem] = [
        ExerciseSessionItem(id: UUID(), title: "Fri, Oct 30", value: "20 kg /side", sets: "4×8", failed: false),
        ExerciseSessionItem(id: UUID(), title: "Wed, Oct 21", value: "17.5 kg /side", sets: "4×8", failed: false),
        ExerciseSessionItem(id: UUID(), title: "Wed, Oct 14", value: "17.5 kg /side", sets: "4×8", failed: true),
        ExerciseSessionItem(id: UUID(), title: "Fri, Sep 18", value: "27.5 kg /side", sets: "4×6", failed: false),
        ExerciseSessionItem(id: UUID(), title: "Fri, Sep 4", value: "27.5 kg /side", sets: "4×6", failed: false),
        ExerciseSessionItem(id: UUID(), title: "Fri, Aug 14", value: "27.5 kg /side", sets: "4×6", failed: false),
        ExerciseSessionItem(id: UUID(), title: "Fri, Aug 7", value: "25 kg /side", sets: "4×6", failed: false),
        ExerciseSessionItem(id: UUID(), title: "Wed, Jul 29", value: "22.5 kg /side", sets: "4×6", failed: true),
    ]
}
#endif
