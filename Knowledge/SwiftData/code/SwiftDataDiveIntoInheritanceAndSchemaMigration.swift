// SwiftData: Dive into inheritance and schema migration
// WWDC25 session 291 · https://developer.apple.com/videos/play/wwdc2025/291/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [01:07] Import SwiftData and add @Model

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
class BucketListItem { ... }

@Model
class LivingAccommodation { ... }

// MARK: - [01:18] Add modelContainer modifier

// SampleTrip App using modelContainer Scene modifier

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

// MARK: - [01:30] Adopt @Query

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

// MARK: - [03:28] Add subclasses to Trip

// Trip Model extended with two new subclasses

@Model
class Trip { 
  var name: String
  var destination: String
  var startDate: Date
  var endDate: Date
  
  var bucketList: [BucketListItem] = [BucketListItem]()
  var livingAccommodation: LivingAccommodation?
}

@available(iOS 26, *)
@Model
class BusinessTrip: Trip {
  var perdiem: Double = 0.0
}

@available(iOS 26, *)
@Model
class PersonalTrip: Trip {
  enum Reason: String, CaseIterable, Codable {
    case family
    case reunion
    case wellness
  }
  
  var reason: Reason
}

// MARK: - [04:03] Update modelContainer modifier

// SampleTrip App using modelContainer Scene modifier

import SwiftUI
import SwiftData

@main
struct TripsApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(for: [Trip.self, BusinessTrip.self, PersonalTrip.self])
  }
}

// MARK: - [07:06] Add segmented control to drive a predicate to filter by Type
// (segment is never declared and the classPredicate closure is never called, as published)

// Trip App add segmented control
import SwiftUI
import SwiftData

struct ContentView: View {
  @Query
  var trips: [Trip]
  
  enum Segment: String, CaseIterable {
    case all = "All"
    case personal = "Personal"
    case business = "Business"
  }
  
  init() {
    let classPredicate: Predicate<Trip>? = {
      switch segment.wrappedValue {
      case .personal:
        return #Predicate { $0 is PersonalTrip }
      case .business:
        return #Predicate { $0 is BusinessTrip }
      default:
        return nil
      }
    }
    _trips = Query(filter: classPredicate, sort: \.startDate, order: .forward)
  }
  
  var body: some View { ... }
}

// MARK: - [08:26] SampleTrips Versioned Schema 2.0

enum SampleTripsSchemaV2: VersionedSchema {
  static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
  static var models: [any PersistentModel.Type] {
    [SampleTripsSchemaV2.Trip.self, BucketListItem.self, LivingAccommodation.self]
  }

  @Model
  class Trip {
    @Attribute(.unique) var name: String
    var destination: String

    @Attribute(originalName: "start_date") var startDate: Date
    @Attribute(originalName: "end_date") var endDate: Date
    
    var bucketList: [BucketListItem]? = []
    var livingAccommodation: LivingAccommodation?
    
    ...
  }
}

// MARK: - [08:41] SampleTrips Custom Migration Stage from Version 1.0 to 2.0

static let migrateV1toV2 = MigrationStage.custom(
   fromVersion: SampleTripsSchemaV1.self,
   toVersion: SampleTripsSchemaV2.self,
   willMigrate: { context in
      let fetchDesc =  FetchDescriptor<SampleTripsSchemaV1.Trip>()
      let trips = try? context.fetch(fetchDesc)
  
      // De-duplicate Trip instances here...

      try? context.save()
    }, 
    didMigrate: nil
)

// MARK: - [09:09] SampleTrips Versioned Schema 3.0
// (hashModifier:@"v3" is not valid Swift; shipped form is @Attribute(hashModifier: "v3"), as published)

enum SampleTripsSchemaV3: VersionedSchema {
  static var versionIdentifier: Schema.Version { Schema.Version(3, 0, 0) }
  static var models: [any PersistentModel.Type] {
    [SampleTripsSchemaV3.Trip.self, BucketListItem.self, LivingAccommodation.self]
  }

  @Model
  class Trip {
    #Unique<Trip>([\.name, \.startDate, \.endDate])
    #Index<Trip>([\.name], [\.startDate], [\.endDate], [\.name, \.startDate, \.endDate])

    @Attribute(.preserveValueOnDeletion)
    var name: String
    
    @Attribute(hashModifier:@"v3")
    var destination: String

    @Attribute(.preserveValueOnDeletion, originalName: "start_date")
    var startDate: Date

    @Attribute(.preserveValueOnDeletion, originalName: "end_date")
    var endDate: Date
  }
}

// MARK: - [09:33] SampleTrips Custom Migration Stage from Version 2.0 to 3.0

static let migrateV2toV3 = MigrationStage.custom(
  fromVersion: SampleTripsSchemaV2.self,
  toVersion: SampleTripsSchemaV3.self,
  willMigrate: { context in
    let trips = try? context.fetch(FetchDescriptor<SampleTripsSchemaV2.Trip>())

    // De-duplicate Trip instances here...

    try? context.save()
  }, 
  didMigrate: nil
)

// MARK: - [09:50] SampleTrips Versioned Schema 4.0

@available(iOS 26, *)
enum SampleTripsSchemaV4: VersionedSchema {
  static var versionIdentifier: Schema.Version { Schema.Version(4, 0, 0) }

  static var models: [any PersistentModel.Type] {
    [Trip.self, 
     BusinessTrip.self, 
     PersonalTrip.self, 
     BucketListItem.self,
     LivingAccommodation.self]
  }
}

// MARK: - [10:03] SampleTrips Lightweight Migration Stage from Version 3.0 to 4.0

@available(iOS 26, *)
static let migrateV3toV4 = MigrationStage.lightweight(
  fromVersion: SampleTripsSchemaV3.self,
  toVersion: SampleTripsSchemaV4.self
)

// MARK: - [10:24] SampleTrips Schema Migration Plan

enum SampleTripsMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] {
    var currentSchemas: [any VersionedSchema.Type] =
      [SampleTripsSchemaV1.self, SampleTripsSchemaV2.self, SampleTripsSchemaV3.self]
    if #available(iOS 26, *) {
      currentSchemas.append(SampleTripsSchemaV4.self)
    }
    return currentSchemas
  }

  static var stages: [MigrationStage] {
    var currentStages = [migrateV1toV2, migrateV2toV3]
    if #available(iOS 26, *) {
      currentStages.append(migrateV3toV4)
    }
    return currentStages
  }
}

// MARK: - [10:51] Use Schema Migration Plan with ModelContainer
// (the closure assigns to an undeclared local container and the catch body is elided, as published)

// SampleTrip App update modelContainer Scene modifier for migrated container

@main
struct TripsApp: App {

  let container: ModelContainer = {
    do {
      let schema = Schema(versionedSchema: SampleTripsSchemaV4.self)
      container = try ModelContainer(
        for: schema, migrationPlan: SampleTripsMigrationPlan.self)
    } catch { ... }
    return container
  }()
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(container)
  }
}

// MARK: - [11:48] Add search predicate to Query
// (segment is never declared and the classPredicate closure is never called, as published)

// Trip App add search text to predicate
struct ContentView: View {
  @Query
  var trips: [Trip]

  init( ... ) {
    let classPredicate: Predicate<Trip>? = {
      switch segment.wrappedValue {
      case .personal:
        return #Predicate { $0 is PersonalTrip }
      case .business:
        return #Predicate { $0 is BusinessTrip }
      default:
        return nil
      }
    }
    
    let searchPredicate = #Predicate<Trip> {
      searchText.isEmpty ? true : 
        $0.name.localizedStandardContains(searchText) ||              
        $0.destination.localizedStandardContains(searchText)
    }
    
    let fullPredicate: Predicate<Trip>
    if let classPredicate {
      fullPredicate = #Predicate { classPredicate.evaluate($0) &&
                                   searchPredicate.evaluate($0)}
    } else { 
      fullPredicate = searchPredicate
    }
    _trips = Query(filter: fullPredicate, sort: \.startDate, order: .forward)
  }
  var body: some View { ... }
}

// MARK: - [12:31] Tailor SwiftData Fetch in Custom Migration Stage

static let migrateV1toV2 = MigrationStage.custom(
   fromVersion: SampleTripsSchemaV1.self,
   toVersion: SampleTripsSchemaV2.self,
   willMigrate: { context in
      var fetchDesc =  FetchDescriptor<SampleTripsSchemaV1.Trip>()
      fetchDesc.propertiesToFetch = [\.name]

      let trips = try? context.fetch(fetchDesc)
  
      // De-duplicate Trip instances here...

      try? context.save()
    }, 
    didMigrate: nil
)

// MARK: - [13:11] Add relationshipsToPrefetch in Custom Migration Stage

static let migrateV1toV2 = MigrationStage.custom(
   fromVersion: SampleTripsSchemaV1.self,
   toVersion: SampleTripsSchemaV2.self,
   willMigrate: { context in
      var fetchDesc =  FetchDescriptor<SampleTripsSchemaV1.Trip>()
      fetchDesc.propertiesToFetch = [\.name]
      fetchDesc.relationshipKeyPathsForPrefetching = [\.livingAccommodation]

      let trips = try? context.fetch(fetchDesc)
  
      // De-duplicate Trip instances here...

      try? context.save()
    }, 
    didMigrate: nil
)

// MARK: - [13:28] Update Widget to harness fetchLimit

// Widget code to get new Timeline Entry

func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
  let currentDate = Date.now
  var fetchDesc = FetchDescriptor(sortBy: [SortDescriptor(\Trip.startDate, order: .forward)])
  fetchDesc.predicate = #Predicate { $0.endDate >= currentDate }

  fetchDesc.fetchLimit = 1
  
  let modelContext = ModelContext(DataModel.shared.modelContainer)
  if let upcomingTrips = try? modelContext.fetch(fetchDesc) {
    if let trip = upcomingTrips.first { ... }
    
  }
}

// MARK: - [16:24] Fetch the last transaction efficiently

// Fetch history with sortBy and fetchlimit to get the last token

var historyDesc = HistoryDescriptor<DefaultHistoryTransaction>()
historyDesc.sortBy = [.init(\.transactionIdentifier, order: .reverse)]
historyDesc.fetchLimit = 1

let transactions = try context.fetchHistory(historyDesc)
if let transaction = transactions.last {
  historyToken = transaction.token
}

// MARK: - [17:29] Fetch History after the given token and only for the entities of concern
// (entityNames holds model types but is compared against entityName strings, as published)

// Changes AFTER the last known token
let tokenPredicate = #Predicate<DefaultHistoryTransaction> { $0.token > historyToken }

// Changes for ONLY entities of concern
let entityNames = [LivingAccommodation.self, Trip.self]
let changesPredicate = #Predicate<DefaultHistoryTransaction> {
                         $0.changes.contains { change in
                           entityNames.contains(change.changedPersistentIdentifier.entityName)
                         }
                       }


let fullPredicate = #Predicate<DefaultHistoryTransaction> {
                      tokenPredicate.evaluate($0)
                      &&
                      changesPredicate.evaluate($0)
                    }

let historyDesc = HistoryDescriptor<DefaultHistoryTransaction>(predicate: fullPredicate)
let transactions = try context.fetchHistory(historyDesc)
