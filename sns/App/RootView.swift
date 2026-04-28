import SwiftUI

struct RootView: View {
    @State private var appState = AppState.mock()

    private var networkTabSymbolName: String {
        SystemSymbol.firstAvailable(
            [
                "point.3.connected.trianglepath.fill",
                "point.3.connected.trianglepath",
                "network",
                "globe.americas.fill",
                "globe"
            ],
            fallback: "globe"
        )
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NetworkView(appState: appState)
                .tabItem {
                    Label("Network", systemImage: networkTabSymbolName)
                }

            SettingsView(appState: appState)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    RootView()
}
