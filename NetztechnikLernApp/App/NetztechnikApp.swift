import SwiftUI

@main
struct NetztechnikApp: App {
    @StateObject private var library = ContentLibrary()
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(library)
                .environmentObject(progress)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var library: ContentLibrary
    @EnvironmentObject var progress: ProgressStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Heute", systemImage: "house.fill") }
            ModuleListView()
                .tabItem { Label("Lernen", systemImage: "book.fill") }
            ReviewHubView()
                .tabItem { Label("Wiederholen", systemImage: "arrow.triangle.2.circlepath") }
                .badge(progress.dueItemIDs().count)
            CalcHubView()
                .tabItem { Label("Rechnen", systemImage: "function") }
            ExamHubView()
                .tabItem { Label("Klausur", systemImage: "timer") }
        }
        .liquidTabBar()
    }
}
