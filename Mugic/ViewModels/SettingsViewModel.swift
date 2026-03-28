import SwiftUI

@Observable
final class SettingsViewModel {
    var crossfadeEnabled: Bool {
        didSet { UserDefaults.standard.set(crossfadeEnabled, forKey: "sonic_crossfade") }
    }
    var audioQuality: String {
        didSet { UserDefaults.standard.set(audioQuality, forKey: "sonic_audio_quality") }
    }
    var themePreference: String {
        didSet { UserDefaults.standard.set(themePreference, forKey: "sonic_theme") }
    }

    var cacheSize: String = "Calculating..."

    let qualityOptions = ["Low", "Normal", "High", "Lossless"]

    init() {
        self.crossfadeEnabled = UserDefaults.standard.object(forKey: "sonic_crossfade") as? Bool ?? true
        self.audioQuality = UserDefaults.standard.string(forKey: "sonic_audio_quality") ?? "Lossless"
        self.themePreference = UserDefaults.standard.string(forKey: "sonic_theme") ?? "Dark"
        updateCacheSize()
    }

    var colorScheme: ColorScheme? {
        switch themePreference {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }

    func updateCacheSize() {
        cacheSize = PersistenceService.formattedCacheSize()
    }

    func clearCache() {
        PersistenceService.clearCache()
        updateCacheSize()
        HapticService.success()
    }
}
