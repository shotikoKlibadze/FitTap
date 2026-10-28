// Build a multi-device workout app
// WWDC23 session 10023 · https://developer.apple.com/videos/play/wwdc2023/10023/
// Transcript ingested into ../README.md §3 (mirrored workout sessions Watch ↔ iPhone, sendData to remote session, cycling data types, iPad authorization).
// The session page publishes no code snippets. The excerpts below come from Apple's companion sample project
// "Building a multidevice workout app" (MirroringWorkoutsSample, Xcode 15), trimmed to the mirroring essentials.
// Copyright Apple Inc.; see the sample's LICENSE.txt. The sample uses ObservableObject + @Published; on iOS 17+
// the same manager works as an @Observable class.

import Foundation
import HealthKit
import SwiftUI

// MARK: - Project setup (from the sample's build settings)
//
// Both targets: HealthKit capability (com.apple.developer.healthkit),
//   NSHealthShareUsageDescription + NSHealthUpdateUsageDescription.
// Watch target Info.plist: WKBackgroundModes = [workout-processing],
//   WKCompanionAppBundleIdentifier = <iOS app bundle ID>.
// Runs on physical devices only (iPhone + paired Apple Watch).

// MARK: - Shared manager: one class, compiled into both apps

@MainActor
final class WorkoutManager: NSObject, ObservableObject {
    struct SessionStateChange {
        let newState: HKWorkoutSessionState
        let date: Date
    }

    @Published var sessionState: HKWorkoutSessionState = .notStarted
    @Published var heartRate: Double = 0
    @Published var elapsedTimeInterval: TimeInterval = 0
    @Published var workout: HKWorkout?

    let typesToShare: Set = [HKQuantityType.workoutType(), HKQuantityType(.dietaryWater)]
    let typesToRead: Set = [HKQuantityType(.heartRate), HKQuantityType(.activeEnergyBurned), HKQuantityType.workoutType()]

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?          // primary on Watch, mirrored on iPhone — keep a strong reference
    #if os(watchOS)
    var builder: HKLiveWorkoutBuilder?      // the live builder exists only on watchOS
    #endif

    // Swift actors don't process tasks first-in-first-out. Funnel state changes through an
    // AsyncStream that keeps only the newest element, and consume it in one loop so the
    // async work for each change (send elapsed time, finish the builder) runs serially.
    let stateStream = AsyncStream.makeStream(of: SessionStateChange.self, bufferingPolicy: .bufferingNewest(1))

    static let shared = WorkoutManager()

    private override init() {
        super.init()
        Task {
            for await change in stateStream.stream {
                await consumeSessionStateChange(change)
            }
        }
    }

    private func consumeSessionStateChange(_ change: SessionStateChange) async {
        sessionState = change.newState
        #if os(watchOS)
        // Tell the iPhone the elapsed time at this state change so both timers agree.
        let elapsed = session?.associatedWorkoutBuilder().elapsedTime(at: change.date) ?? 0
        if let data = try? JSONEncoder().encode(WorkoutElapsedTime(timeInterval: elapsed, date: change.date)) {
            await sendData(data)
        }
        // End only after the session reports .stopped: end collection → finish → end session.
        guard change.newState == .stopped, let builder else { return }
        do {
            try await builder.endCollection(at: change.date)
            workout = try await builder.finishWorkout()
            session?.end()
        } catch {
            print("Failed to end workout: \(error)")
        }
        #endif
    }

    /// Either side sends arbitrary Data to the other side's session.
    func sendData(_ data: Data) async {
        do {
            try await session?.sendToRemoteWorkoutSession(data: data)
        } catch {
            print("Failed to send data: \(error)")
        }
    }
}

struct WorkoutElapsedTime: Codable {
    var timeInterval: TimeInterval
    var date: Date
}

// MARK: - Session delegate (both sides)
// HealthKit calls delegates on an anonymous serial background queue, so the methods are nonisolated.

extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        stateStream.continuation.yield(SessionStateChange(newState: toState, date: date))
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}

    /// The mirrored session became invalid (e.g. mirroring stopped).
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didDisconnectFromRemoteDeviceWithError error: Error?) {}

    /// While the app is suspended, HealthKit buffers incoming data and delivers it as one
    /// array, in arrival order, when the app resumes (iOS, and watchOS if the system suspended it).
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didReceiveDataFromRemoteWorkoutSession data: [Data]) {
        Task { @MainActor in
            for element in data {
                try? handleReceivedData(element)
            }
        }
    }
}

// MARK: - iPhone side

#if os(iOS)
extension WorkoutManager {
    /// Launches the Watch app and hands it the configuration.
    func startWatchWorkout(activityType: HKWorkoutActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = .outdoor
        try await healthStore.startWatchApp(toHandle: configuration)
    }

    /// Register at every launch, foreground or background: HealthKit calls it when the Watch starts mirroring.
    func retrieveRemoteSession() {
        healthStore.workoutSessionMirroringStartHandler = { mirroredSession in
            Task { @MainActor in
                self.session = mirroredSession
                self.session?.delegate = self
            }
        }
    }

    func handleReceivedData(_ data: Data) throws {
        if let elapsed = try? JSONDecoder().decode(WorkoutElapsedTime.self, from: data) {
            // Running: add the time since the Watch stamped it. Paused: take it as is.
            elapsedTimeInterval = session?.state == .running
                ? elapsed.timeInterval + Date().timeIntervalSince(elapsed.date)
                : elapsed.timeInterval
        } else if let statistics = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: HKStatistics.self, from: data) {
            statistics.forEach(updateForStatistics)
        }
    }

    /// iPhone → Watch: a quantity the Watch will save into the workout.
    func recordWater() async {
        let water = HKQuantity(unit: .fluidOunceUS(), doubleValue: 1)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: water, requiringSecureCoding: true) {
            await sendData(data)
        }
    }

    /// Controls work from the mirrored side too; HealthKit syncs the state to the Watch.
    func pause() { session?.pause() }
    func resume() { session?.resume() }
    func end() { session?.stopActivity(with: .now) }
}

/// iPhone/iPad authorization: SwiftUI modifier from HealthKitUI, presented over the right scene.
/// .healthDataAccessRequest(store: manager.healthStore, shareTypes: manager.typesToShare,
///                          readTypes: manager.typesToRead, trigger: trigger) { result in … }
#endif

// MARK: - Watch side

#if os(watchOS)
import WatchKit

/// Receives the configuration sent by startWatchApp(toHandle:).
final class AppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        Task { @MainActor in
            try await WorkoutManager.shared.startWorkout(configuration: workoutConfiguration)
        }
    }
}
// In the App: @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

extension WorkoutManager {
    /// watchOS has no healthDataAccessRequest modifier here; request directly.
    func requestAuthorization() async throws {
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }

    func startWorkout(configuration: HKWorkoutConfiguration) async throws {
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        try await session?.startMirroringToCompanionDevice()   // mirror first…
        let startDate = Date()
        session?.startActivity(with: startDate)                // …then start the activity
        try await builder?.beginCollection(at: startDate)
    }

    /// Watch ← iPhone: save the received quantity as a sample in the live workout.
    func handleReceivedData(_ data: Data) throws {
        guard let quantity = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQuantity.self, from: data) else { return }
        let now = Date()
        Task {
            try await builder?.addSamples([HKQuantitySample(type: HKQuantityType(.dietaryWater), quantity: quantity, start: now, end: now)])
        }
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    /// Watch → iPhone: archive the fresh statistics (HKStatistics supports secure coding) and send them.
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Task { @MainActor in
            let statistics = collectedTypes
                .compactMap { $0 as? HKQuantityType }
                .compactMap { workoutBuilder.statistics(for: $0) }
            statistics.forEach(updateForStatistics)
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: statistics, requiringSecureCoding: true) else { return }
            await sendData(data)
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
#endif

// MARK: - Statistics → published values (both sides)

extension WorkoutManager {
    func updateForStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0
        default:
            break   // the sample also maps active energy, distance, cycling speed/power/cadence
        }
    }
}

// MARK: - Live elapsed-time display that stops ticking while paused

struct MetricsTimelineSchedule: TimelineSchedule {
    let startDate: Date
    let isPaused: Bool

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        // 30 fps normally; once per second in always-on (low frequency) mode.
        var base = PeriodicTimelineSchedule(from: self.startDate, by: mode == .lowFrequency ? 1 : 1.0 / 30)
            .entries(from: startDate, mode: mode)
        return AnyIterator { isPaused ? nil : base.next() }
    }
}
// Usage: TimelineView(MetricsTimelineSchedule(from: session?.startDate ?? .now, isPaused: sessionState == .paused)) { context in … }
