import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "flag")
                }
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

