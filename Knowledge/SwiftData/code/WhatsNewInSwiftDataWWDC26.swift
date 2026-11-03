// What’s new in SwiftData
// WWDC26 session 274 · https://developer.apple.com/videos/play/wwdc2026/274/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [00:01] Sectioned fetching
// (var body: some View: { is a syntax error and $selection is never declared, as published)

// Sectioned fetching

struct TripListView: View {   
    @Query(sort: \Trip.startDate,
           sectionBy: \.destination)
    var trips: [Trip]

    var body: some View: {
        List(selection: $selection) {
            ForEach(_trips.sections) {section in
                Section(section.id) {
                    ForEach(trips) {trip in
                        TripListItem(trip: trip)
                    }
               }
            }
        }
    }
}

// MARK: - [04:59] Using Codable

// Using Codable

import SwiftData

@Model class Trip {

    struct Location: Codable {
        var latitude: Double
        var longitude: Double
    }

    var name: String
    var destination: String

    var startDate: Date
    var endDate: Date

    var location: Location?
    @Attribute(.codable) var mapItemIdentifier: MKMapItem.Identifier?
}

// MARK: - [08:20] // Use observation to update map bounds
// ({[weak self], event in is a syntax error and the calculateBounds body is a broken / * */ comment, as published)

// Use observation to update map bounds

@Observable @MainActor final class MapCameraController {
    private let resultsObserver: ResultsObserver<Trip, Never>
    var bounds: MapCameraBounds?
    private var token: ObservationTracking.Token?

    init(modelContext: ModelContext) throws {
        resultsObserver = try ResultsObserver<Trip, Never>(modelContext: modelContext)

        token = withContinuousObservation(options: [.didSet]) {[weak self], event in
            self?.bounds = self?.calculateBounds(trips: resultsObserver.results)
       }
    }

    private func calculateBounds(trips: [Trip]) -> MapCameraBounds? { / * */ }
}

// MARK: - [08:21] // Using HistoryObserver to sync with a server
// (a let observer is assigned inside start() and modelContainer is never declared, as published)

// Using HistoryObserver to sync with a server

@SyncActor final class ServerSync {
    private let observer: HistoryObserver
    private var token: ObservationTracking.Token?

    func start() throws {
        self.observer = try HistoryObserver(authors: ["App"], modelContainer: modelContainer)
        token = withContinuousObservation(options: .didSet) {[weak self] _ in
            _ = self?.observer.eventCounter
            self?.processChanges()
        }
    }

    private func processChanges() {
        // Fetch and process history transactions
    }
}
