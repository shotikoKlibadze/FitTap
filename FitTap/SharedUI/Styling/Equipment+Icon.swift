import SwiftUI

/// Equipment glyphs for exercise rows and pickers — SF Symbols, mapped in
/// one place so every list draws the same icon per equipment.
extension Equipment {
    var icon: Image {
        switch self {
        case .barbell, .ezBar: Image(systemName: "figure.strengthtraining.traditional")
        case .dumbbell: Image(systemName: "dumbbell")
        case .cable: Image(systemName: "cable.connector")
        case .machine: Image(systemName: "gearshape.2")
        case .kettlebell: Image(systemName: "scalemass")
        case .bodyweight: Image(systemName: "figure.stand")
        case .pullUpBar: Image(systemName: "figure.strengthtraining.functional")
        case .bench: Image(systemName: "rectangle.portrait")
        case .other: Image(systemName: "circle.grid.2x2")
        }
    }
}
