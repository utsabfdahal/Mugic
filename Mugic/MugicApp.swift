import SwiftUI

@main
struct MugicApp: App {
    @State private var player = PlayerViewModel()
    @State private var library = LibraryViewModel()
    @State private var settings = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(player)
                .environment(library)
                .environment(settings)
                .preferredColorScheme(settings.colorScheme)
        }
    }
}
