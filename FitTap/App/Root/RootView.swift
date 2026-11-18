import NavigatorUI
import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()

    var body: some View {
        ZStack {
            if viewModel.showsOnboarding {
                ManagedNavigationStack {
                    OnboardingScreen(onFinish: finishOnboarding)
                }
                .transition(.opacity)
            } else {
                tabs
                    .transition(.opacity)
            }
        }
    }

    private var tabs: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                ManagedNavigationStack { HomeScreen() }
            }
            Tab("Workouts", systemImage: "dumbbell", value: AppTab.workouts) {
                ManagedNavigationStack { WorkoutsScreen() }
            }
            Tab("Stats", systemImage: "chart.bar", value: AppTab.stats) {
                ManagedNavigationStack { StatsScreen() }
            }
        }
    }

    private func finishOnboarding() {
        withAnimation(.smooth(duration: 0.4)) { viewModel.finishOnboarding() }
    }
}
