# Dependency injection — reference examples

Full code examples for the rules in [SKILL.md](SKILL.md). Read the section a task needs.

## 1. Registrations in `Core/Dependencies/Container+Dependencies.swift`

```swift
import FactoryKit

extension Container {
    /// One client for the process lifetime.
    @MainActor
    var apiClient: Factory<APIClient> {
        self {
            MainActor.assumeIsolated {
                APIClient(baseURL: AppEnvironment.current.baseURL)
            }
        }
        .singleton
    }

    @MainActor
    var workoutStore: Factory<any WorkoutStore> {
        self {
            MainActor.assumeIsolated { () -> any WorkoutStore in
                #if DEBUG
                    if AppDataSource.usesMocks { return MockWorkoutStore() }
                #endif
                return LiveWorkoutStore(client: self.apiClient())
            }
        }
        .singleton
    }
}
```

## 2. Consuming in a screen model

```swift
@MainActor
@Observable
final class SomeScreenModel {
    @ObservationIgnored
    @Injected(\.dateManager) private var dateManager

    @ObservationIgnored
    @DynamicInjected(\.workoutStore) private var workoutStore

    // screen state and behavior only
}
```

## 3. Scope reset on sign-out

```swift
extension Container {
    @MainActor
    func resetUserScopedStores() {
        workoutStore.reset(.scope)
        profileStore.reset(.scope)
        // infrastructure that outlives a session (apiClient, authManager) is NOT reset
    }
}
```

## 4. Test or preview override

```swift
Container.shared.workoutStore.register { MockWorkoutStore() }
defer { Container.shared.reset() }
```
