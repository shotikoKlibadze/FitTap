// Track workouts with HealthKit on iOS and iPadOS
// WWDC25 session 322 · https://developer.apple.com/videos/play/wwdc2025/322/
// Apple's sample code as published on the session page, one block per snippet, in video order.
// Explanations: ../README.md

// MARK: - [1:30] Set up workout session

// Set up workout session

// Create workout configuration
let configuration = HKWorkoutConfiguration()
configuration.activityType = .running
configuration.locationType = .outdoor

// Create workout session
let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
session.delegate = self

// Get associated workout builder and add data source
let builder = session.associatedWorkoutBuilder()
builder.delegate = self
builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                             workoutConfiguration: configuration)

// MARK: - [1:54] Starting the session

// Prepare and start session

session.prepare()

// Start and display count down

// Start session and builder collection once count down finishes
session.startActivity(with: startDate)
try await builder.beginCollection(at: startDate)

// MARK: - [2:14] Handling Metrics

// Handling collected metrics

func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, 
                    didCollectDataOf collectedTypes: Set<HKSampleType>) {
    for type in collectedTypes {
        guard let quantityType = type as? HKQuantityType else { return }

        let statistics = workoutBuilder.statistics(for: quantityType)

        // Update the published values
        updateForStatistics(statistics)
    }
}

// MARK: - [2:28] Ending workout

// Stopping the workout session

session.stopActivity(with: .now)

// Session transitions to stopped then call end
func workoutSession(_ workoutSession: HKWorkoutSession,
                    didChangeTo toState: HKWorkoutSessionState,
                    from fromState: HKWorkoutSessionState,
                    date: Date) {
    guard change.newState == .stopped, let builder else { return }
     
    try await builder.endCollection(at: change.date)
    let finishedWorkout = try await builder.finishWorkout()
    session.end()
}

// MARK: - [7:17] Set up Siri Intent

// Create an INExtension within your main app

// Define an intent handler
public class IntentHandler: INExtension {

}

// Define the intents to support
extension IntentHandler: INStartWorkoutIntentHandling

extension IntentHandler: INPauseWorkoutIntentHandling

extension IntentHandler: INResumeWorkoutIntentHandling

extension IntentHandler: INEndWorkoutIntentHandling

// MARK: - [7:32] Handle the Siri intent

// Handle the intent

public func handle(intent: INStartWorkoutIntent) async -> INStartWorkoutIntentResponse {
    let state = await WorkoutManager.shared.state
        
    switch state {
    case .running, .paused, .prepared, .stopped:
        return INStartWorkoutIntentResponse(code: .failureOngoingWorkout, 
                                            userActivity: nil)
    default:
        break;
    }
    Task {
        await MainActor.run {
            // Handle the intents activity type and location
            WorkoutManager.shared.setWorkoutConfiguration(activityType: .running,   
                                                          location: .outdoor)
        }
    }
    return INStartWorkoutIntentResponse(code: .success, userActivity: nil)
 }

// MARK: - [7:52] App Delegate

// Implement an app delegate

// Create app delegate
class WorkoutsOniOSSampleAppDelegate: NSObject, UIApplicationDelegate {
    let handler = IntentHandler()

    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        return handler
    }
}

// Add app delegate to app
struct WorkoutsOniOSSampleApp: App {
    @UIApplicationDelegateAdaptor(WorkoutsOniOSSampleAppDelegate.self) var appDelegate

}

// MARK: - [9:09] Set up crash recovery

// App Delegate

func application(_ application: UIApplication,
                 configurationForConnecting connectingSceneSession: UISceneSession,
                 options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    if options.shouldHandleActiveWorkoutRecovery {
        let store = HKHealthStore()
        store.recoverActiveWorkoutSession(completion: { (workoutSession, error) in
            // Handle error
            Task {
                await WorkoutManager.shared.recoverWorkout(recoveredSession: workoutSession)
            }
        })
    }
    let configuration = UISceneConfiguration(name: "Default Configuration", 
                                             sessionRole: connectingSceneSession.role)
    configuration.delegateClass = WorkoutsOniOSSampleAppSceneDelegate.self
    return configuration
}

// MARK: - [9:25] Recover the workout session

// Recover the workout for the session


func recoverWorkout(recoveredSession: HKWorkoutSession) {
    session = recoveredSession
    builder = recoveredSession.associatedWorkoutBuilder()
    session?.delegate = self
    builder?.delegate = self
    workoutConfiguration = recoveredSession.workoutConfiguration

    let dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,                                                                  
                                             workoutConfiguration: workoutConfiguration)
    builder?.dataSource = dataSource
}
