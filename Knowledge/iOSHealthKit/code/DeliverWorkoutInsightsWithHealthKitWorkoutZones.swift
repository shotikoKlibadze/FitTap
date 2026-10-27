// Deliver workout insights with HealthKit workout zones
// WWDC26 session 207 · https://developer.apple.com/videos/play/wwdc2026/207/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [3:54] Reading Heart Rate Zones from a completed workout

// Read heart rate zones from the completed workout

if let heartRateZoneGroup = workout.zoneGroupsByType?[HKQuantityType(.heartRate)] {
let zones = ZoneDisplayData(
    zoneCount: heartRateZoneGroup.configuration.zones.count,
    currentZoneIndex: nil,
    durations: heartRateZoneGroup.zoneDurations.map(\.duration)
)

// MARK: - [7:57] Handling Live Zone Updates

func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                    didUpdateWorkoutZone zoneUpdate: HKLiveWorkoutZoneUpdate) {
    guard let zoneGroup = zoneUpdate.zoneGroup else {
        return
    }
    if let currentIndex = zoneUpdate.currentZoneDuration?.zone.index {
        let data = ZoneDisplayData(
            zoneCount: zoneGroup.configuration.zones.count,
            currentZoneIndex: currentIndex,
            durations: zoneGroup.zoneDurations.map(\.duration)
        )
        Task { @MainActor in
            self.heartRateZones = data
        }
    }
}

// MARK: - [9:19] Check if Preferred Zone has been set

if try await builder.zoneConfiguration(for: HKQuantityType(.heartRate)) == nil {

// MARK: - [9:24] Create Zone Boundaries

let defaultHeartRateZoneThresholds = [91.0, 114.0, 136.0, 158.0]
    let bpmUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
    let boundaries = defaultHeartRateZoneThresholds.map(
        {HKQuantity(unit: bpmUnit, doubleValue:$0)}
    )

// MARK: - [9:33] Create Default Workout Zone Configuration

let heartRate = HKQuantityType(.heartRate)
    let defaultConfiguration = try HKWorkoutZoneConfiguration(quantityType: heartRate,
                                                              zoneBoundaries: boundaries)

// MARK: - [9:58] Set Custom Zone Configuration

try await builder.setCustomZoneConfiguration(defaultConfiguration,
                                                 for: heartRate)
}

// MARK: - [10:03] Begin Data Collection

// Begin data collection
let startDate = Date()
try await builder.beginCollection(at: startDate)
