// Dive deeper into SwiftData
// WWDC23 session 10196 · https://developer.apple.com/videos/play/wwdc2023/10196/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [01:45] Trip model with cascading relationships
// (Pre-release shape: shipped API is @Relationship(deleteRule: .cascade), as published)

@Model
final class Trip {
    var destination: String?
    var end_date: Date?
    var name: String?
    var start_date: Date?
  
    @Relationship(.cascade)
    var bucketListItem: [BucketListItem] = [BucketListItem]()
  
    @Relationship(.cascade)
    var livingAccommodation: LivingAccommodation?
}

// MARK: - [04:21] Initializing a ModelContainer

// ModelContainer initialized with just Trip
let container = try ModelContainer(for: Trip.self)

// SwiftData infers related model classes as well
let container = try ModelContainer(
    for: [
        Trip.self, 
        BucketListItem.self, 
        LivingAccommodation.self
    ]
)

// MARK: - [05:41] Using ModelConfiguration to customize ModelContainer
// (Pre-release shape: shipped init is ModelContainer(for:configurations:); LivingAccommodations vs LivingAccommodation naming differs from the model, as published)

let fullSchema = Schema([
    Trip.self,
    BucketListItem.self,
    LivingAccommodations.self,
    Person.self,
    Address.self
])

let trips = ModelConfiguration(
    schema: Schema([
        Trip.self,
        BucketListItem.self,
        LivingAccommodations.self
    ]),
    url: URL(filePath: "/path/to/trip.store"),
    cloudKitContainerIdentifier: "com.example.trips"
)

let people = ModelConfiguration(
    schema: Schema([Person.self, Address.self]),
    url: URL(filePath: "/path/to/people.store"),
    cloudKitContainerIdentifier: "com.example.people"
) 

let container = try ModelContainer(for: fullSchema, trips, people)

// MARK: - [06:49] Creating ModelContainer in SwiftUI
// (Does not compile: try in a stored-property initializer; same ModelContainer(for:configurations:) caveat, as published)

@main
struct TripsApp: App {
    let fullSchema = Schema([
        Trip.self, 
        BucketListItem.self,
        LivingAccommodations.self,
        Person.self, 
        Address.self
    ])
  
    let trips = ModelConfiguration(
        schema: Schema([
            Trip.self,
            BucketListItem.self,
            LivingAccommodations.self
        ]),
        url: URL(filePath: "/path/to/trip.store"),
        cloudKitContainerIdentifier: "com.example.trips"
    )
  
    let people = ModelConfiguration(
        schema: Schema([
            Person.self, 
            Address.self
        ]),
        url: URL(filePath: "/path/to/people.store"),
        cloudKitContainerIdentifier: "com.example.people"
    )
  
    let container = try ModelContainer(for: fullSchema, trips, people)
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

// MARK: - [07:40] Using the modelContainer modifier

@main
struct TripsApp: App {
   var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self)
    }
}

// MARK: - [07:50] Referencing a ModelContext in SwiftUI views
// (Fragment: path, selection and deleteTrips(at:) are not declared, as published)

struct ContentView: View {
    @Query var trips: [Trip]
    @Environment(\.modelContext) var modelContext
  
    var body: some View {
        NavigationStack (path: $path) {
            List(selection: $selection) {
                ForEach(trips) { trip in
                    TripListItem(trip: trip)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(trip)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: deleteTrips(at:))
            }
        }
    }
}

// MARK: - [09:57] Enabling undo on a ModelContainer

@main
struct TripsApp: App {
   @Environment(\.undoManager) var undoManager
   var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self, isUndoEnabled: true)
    }
}

// MARK: - [11:05] Enabling autosave on a ModelContainer

@main
struct TripsApp: App {
   var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self, isAutosaveEnabled: false)
    }
}

// MARK: - [11:54] Fetching objects with FetchDescriptor
// (newSwiftContext(from:) is a sample-app helper, not a SwiftData API, as published)

let context = self.newSwiftContext(from: Trip.self)
var trips = try context.fetch(FetchDescriptor<Trip>())

// MARK: - [12:14] Fetching objects with #Predicate and FetchDescriptor
// (newSwiftContext(from:) is a sample-app helper; livingAccommodations is treated as a collection, unlike the Trip model, as published)

let context = self.newSwiftContext(from: Trip.self)
let hotelNames = ["First", "Second", "Third"]

var predicate = #Predicate<Trip> { trip in
    trip.livingAccommodations.filter {
        hotelNames.contains($0.placeName)
    }.count > 0
}

var descriptor = FetchDescriptor(predicate: predicate)
var trips = try context.fetch(descriptor)

// MARK: - [12:27] Fetching objects with #Predicate and FetchDescriptor
// (Continues the previous snippet; redeclares context and trips, as published)

let context = self.newSwiftContext(from: Trip.self)

predicate = #Predicate<Trip> { trip in
    trip.livingAccommodations.filter {
        $0.hasReservation == false
    }.count > 0
}

descriptor = FetchDescriptor(predicate: predicate)
var trips = try context.fetch(descriptor)

// MARK: - [13:18] Enumerating objects with FetchDescriptor
// (Shipped enumerate throws and needs try, as published)

context.enumerate(FetchDescriptor<Trip>()) { trip in
    // Operate on trip
}

// MARK: - [13:36] Enumerating with FetchDescriptor and SortDescriptor
// (descriptor is a let but is mutated; shipped enumerate needs try, as published)

let predicate = #Predicate<Trip> { trip in
    trip.bucketListItem.filter {
        $0.hasReservation == false
    }.count > 0
}

let descriptor = FetchDescriptor(predicate: predicate)
descriptor.sortBy = [SortDescriptor(\.start_date)]

context.enumerate(descriptor) { trip in
    // Remind me to make reservations for trip
}

// MARK: - [14:01] Fine tuning enumerate with batchSize
// (descriptor is a let but is mutated; shipped enumerate needs try, as published)

let predicate = #Predicate<Trip> { trip in
    trip.bucketListItem.filter {
        $0.hasReservation == false
    }.count > 0
}

let descriptor = FetchDescriptor(predicate: predicate)
descriptor.sortBy = [SortDescriptor(\.start_date)]

context.enumerate(
    descriptor,
    batchSize: 10000
) { trip in
    // Remind me to make reservations for trip
}

// MARK: - [14:28] Fine tuning enumerate with batchSize and allowEscapingMutations
// (descriptor is a let but is mutated; shipped enumerate needs try, as published)

let predicate = #Predicate<Trip> { trip in
    trip.bucketListItem.filter {
        $0.hasReservation == false
    }.count > 0
}

let descriptor = FetchDescriptor(predicate: predicate)
descriptor.sortBy = [SortDescriptor(\.start_date)]

context.enumerate(
    descriptor,
    batchSize: 500,
    allowEscapingMutations: true
) { trip in
    // Remind me to make reservations for trip
}
