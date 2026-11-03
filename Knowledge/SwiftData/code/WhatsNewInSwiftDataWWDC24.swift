// What’s new in SwiftData
// WWDC24 session 10137 · https://developer.apple.com/videos/play/wwdc2024/10137/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [01:32] SampleTrips models decorated with @Model
// (model bodies elided with {...}, as published)

// Trip Models decorated with @Model
import Foundation
import SwiftData

@Model
class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    
    var bucketList: [BucketListItem] = [BucketListItem]()
    var livingAccommodation: LivingAccommodation?
}

@Model
class BucketListItem {...}

@Model
class LivingAccommodation {...}

// MARK: - [01:43] SampleTrips using modelContainer scene modifier
// (ContentView is missing its () call, as published)

// Trip App using modelContainer Scene modifier
import SwiftUI
import SwiftData

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView
        }
        .modelContainer(for: Trip.self)
    }
}

// MARK: - [01:53] SampleTrips using @Query
// ($selection is never declared, as published)

// Trip App using @Query
import SwiftUI
import SwiftData

struct ContentView: View {
    @Query
    var trips: [Trip]
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(trips) { trip in
                    TripListItem(trip: trip)
                }
            }
        }
    }
}

// MARK: - [02:16] SampleTrips models decorated with @Model
// (model bodies elided with {...}, as published)

// Trip Models decorated with @Model
import Foundation
import SwiftData

@Model
class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date

    var bucketList: [BucketListItem] = [BucketListItem]()
    var livingAccommodation: LivingAccommodation?
}

@Model
class BucketListItem {...}

@Model
class LivingAccommodation {...}

// MARK: - [03:08] Add unique constraints to avoid duplication

// Add unique constraints to avoid duplication
import SwiftData

@Model 
class Trip {
    #Unique<Trip>([\.name, \.startDate, \.endDate])
    
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    
    var bucketList: [BucketListItem] = [BucketListItem]()
    var livingAccommodation: LivingAccommodation?
}

// MARK: - [03:36] Add .preserveValueOnDeletion to capture unique columns

// Add .preserveValueOnDeletion to capture unique columns
import SwiftData

@Model 
class Trip {
    #Unique<Trip>([\.name, \.startDate, \.endDate])
    
    @Attribute(.preserveValueOnDeletion)
    var name: String
    var destination: String

    @Attribute(.preserveValueOnDeletion)
    var startDate: Date

    @Attribute(.preserveValueOnDeletion)
    var endDate: Date
    
    var bucketList: [BucketListItem] = [BucketListItem]()
    var livingAccommodation: LivingAccommodation?
}

// MARK: - [04:35] SampleTrips using modelContainer scene modifier

// Trip App using modelContainer Scene modifier
import SwiftUI
import SwiftData

@main
struct TripsApp: App {   
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self)
   }
}

// MARK: - [04:52] Customize a model container in the app

// Customize a model container in the app
import SwiftUI
import SwiftData

@main
struct TripsApp: App {   
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self,
                        inMemory: true,
                        isAutosaveEnabled: true,
                        isUndoEnabled: true)
   }
}

// MARK: - [05:13] Add a model container to the app
// (fileURL is undefined and the catch body is elided, as published)

// Add a model container to the app
import SwiftUI
import SwiftData

@main
struct TripsApp: App {
    var container: ModelContainer = {
        do {
            let configuration = ModelConfiguration(schema: Schema([Trip.self]), url: fileURL)
            return try ModelContainer(for: Trip.self, configurations: configuration)
        }
        catch { ... }
    }()
    
   var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
   }
}

// MARK: - [05:59] Use your own custom data store
// (jsonFileURL is undefined; the init labels (schema:url:) do not match the JSONStoreConfiguration(name:schema:fileURL:) from session 10138, as published)

// Use your own custom data store
import SwiftUI
import SwiftData

@main
struct TripsApp: App {
    var container: ModelContainer = {
        do {
            let configuration = JSONStoreConfiguration(schema: Schema([Trip.self]), url: jsonFileURL)
            return try ModelContainer(for: Trip.self, configurations: configuration)
        }
        catch { ... }
    }()
    
   var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
   }
}

// MARK: - [06:58] Make preview data using traits

// Make preview data using traits

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, configurations: config)
        Trip.makeSampleTrips(in: container)
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}

// MARK: - [08:15] Use sample data in a preview
// (view body elided with ..., as published)

/*
// Use sample data in a preview

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query
    var trips: [Trip]

    var body: some View {
        ...
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}
*/

// MARK: - [08:50] Create a preview query using @Previewable

/*
// Create a preview query using @Previewable

import SwiftUI
import SwiftData

#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    BucketListItemView(trip: trips.first)
}
*/

// MARK: - [09:55] Create a predicate to find a Trip based on search text

// Create a Predicate to find a Trip based on Search Text

let predicate = #Predicate<Trip> {
    searchText.isEmpty ? true : $0.name.localizedStandardContains(searchText)
}

// MARK: - [10:06] Create a Compound Predicate to find a Trip based on Search Text

// Create a Compound Predicate to find a Trip based on Search Text

let predicate = #Predicate<Trip> {
    searchText.isEmpty ? true :
    $0.name.localizedStandardContains(searchText) ||
    $0.destination.localizedStandardContains(searchText)
}

// MARK: - [10:46] Build a predicate to find Trips with BucketListItems that are not in the plan
// (the #Predicate closure is missing `in` after `trip`, as published)

// Build a predicate to find Trips with BucketListItems that are not in the plan

let unplannedItemsExpression = #Expression<[BucketListItem], Int> { items in
    items.filter {
        !$0.isInPlan
    }.count
}

let today = Date.now
let tripsWithUnplannedItems = #Predicate<Trip>{ trip
    // The current date falls within the trip
    (trip.startDate ..< trip.endDate).contains(today) &&

    // The trip has at least one BucketListItem
    // where 'isInPlan' is false
    unplannedItemsExpression.evaluate(trip.bucketList) > 0
}

// MARK: - [12:41] Add Index for commonly used KeyPaths or combination of KeyPaths
// (the #Unique line and bucketList default are truncated (missing ]) and ]), and livingAccommodation lost its ?, as published)

// Add Index for commonly used KeyPaths or combination of KeyPaths
import SwiftData

@Model 
class Trip {
    #Unique<Trip>([\.name, \.startDate, \.endDate
    #Index<Trip>([\.name], [\.startDate], [\.endDate], [\.name, \.startDate, \.endDate])

    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    
    var bucketList: [BucketListItem] = [BucketListItem
    var livingAccommodation: LivingAccommodation
}
