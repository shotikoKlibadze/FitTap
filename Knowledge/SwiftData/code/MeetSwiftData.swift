// Meet SwiftData
// WWDC23 session 10187 · https://developer.apple.com/videos/play/wwdc2023/10187/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [01:27] Adding @Model to Trip

import SwiftData

@Model
class Trip {
    var name: String
    var destination: String
    var endDate: Date
    var startDate: Date
 
    var bucketList: [BucketListItem]? = []
    var livingAccommodation: LivingAccommodation?
}

// MARK: - [02:46] Providing options for @Attribute and @Relationship
// (Pre-release shape: shipped API is @Relationship(deleteRule: .cascade), as published)

@Model
class Trip {
    @Attribute(.unique) var name: String
    var destination: String
    var endDate: Date
    var startDate: Date
 
    @Relationship(.cascade) var bucketList: [BucketListItem]? = []
    var livingAccommodation: LivingAccommodation?
}

// MARK: - [03:43] Initialize a ModelContainer
// (Pre-release shape: shipped init needs the for: label; URL("path") is not a real URL initializer; container is declared twice, as published)

// Initialize with only a schema
let container = try ModelContainer([Trip.self, LivingAccommodation.self])

// Initialize with configurations
let container = try ModelContainer(
    for: [Trip.self, LivingAccommodation.self],
    configurations: ModelConfiguration(url: URL("path"))
)

// MARK: - [03:58] Creating a model container in SwiftUI

import SwiftUI

@main
struct TripsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [Trip.self, LivingAccommodation.self]
        )
    }
}

// MARK: - [04:20] Accessing the environment's ModelContext

import SwiftUI

struct ContextView : View {
    @Environment(\.modelContext) private var context
}

// MARK: - [05:13] Building a predicate

let today = Date()
let tripPredicate = #Predicate<Trip> { 
    $0.destination == "New York" &&
    $0.name.contains("birthday") &&
    $0.startDate > today
}

// MARK: - [05:32] Fetching with a FetchDescriptor

let descriptor = FetchDescriptor<Trip>(predicate: tripPredicate)

let trips = try context.fetch(descriptor)

// MARK: - [05:46] Fetching with fetch and sort descriptors
// (Pre-release shape: shipped init is FetchDescriptor(predicate:sortBy:) with sortBy taking an array, as published)

let descriptor = FetchDescriptor<Trip>(
    sortBy: SortDescriptor(\Trip.name),
    predicate: tripPredicate
)

let trips = try context.fetch(descriptor)

// MARK: - [06:15] Working with a ModelContext

var myTrip = Trip(name: "Birthday Trip", destination: "New York")

// Insert a new trip
context.insert(myTrip)

// Delete an existing trip
context.delete(myTrip)

// Manually save changes to the context
try context.save()

// MARK: - [07:38] Using @Query in SwiftUI

import SwiftUI

struct ContentView: View  {
    @Query(sort: \.startDate, order: .reverse) var trips: [Trip]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
       NavigationStack() {
          List {
             ForEach(trips) { trip in 
                 // ...
             }
          }
       }
    }
}
