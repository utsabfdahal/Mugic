import SwiftUI

@main
struct MugicApp: App {
    @State private var player = PlayerViewModel()
    @State private var library = LibraryViewModel()
    @State private var settings = SettingsViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(player)
                    .environment(library)
                    .environment(settings)
                    .preferredColorScheme(settings.colorScheme)

                if showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}
