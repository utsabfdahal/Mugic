import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Adaptive Color Helper
extension Color {
    init(light lightColor: Color, dark darkColor: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(darkColor)
                : UIColor(lightColor)
        })
        #elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(darkColor)
                : NSColor(lightColor)
        })
        #endif
    }
}

// MARK: - Sonic Design System Colors
// Adaptive colors for both light (Luminous) and dark (Kinetic) themes
// Using ShapeStyle extension so implicit member expressions work in .foregroundStyle(), .fill(), etc.
extension ShapeStyle where Self == Color {
    // Core surfaces
    static var sonicBackground: Color { Color(light: Color(hex: "f9f9f9"), dark: Color(hex: "0e0e0f")) }
    static var sonicSurface: Color { Color(light: Color(hex: "f9f9f9"), dark: Color(hex: "0e0e0f")) }
    static var sonicSurfaceContainerLowest: Color { Color(light: .white, dark: Color(hex: "000000")) }
    static var sonicSurfaceContainerLow: Color { Color(light: Color(hex: "f3f3f4"), dark: Color(hex: "131314")) }
    static var sonicSurfaceContainer: Color { Color(light: Color(hex: "eeeeee"), dark: Color(hex: "1a191b")) }
    static var sonicSurfaceContainerHigh: Color { Color(light: Color(hex: "e8e8e8"), dark: Color(hex: "201f21")) }
    static var sonicSurfaceContainerHighest: Color { Color(light: Color(hex: "e2e2e2"), dark: Color(hex: "262627")) }
    static var sonicSurfaceVariant: Color { Color(light: Color(hex: "e2e2e2"), dark: Color(hex: "262627")) }
    static var sonicSurfaceBright: Color { Color(light: Color(hex: "f9f9f9"), dark: Color(hex: "2c2c2d")) }

    // Primary
    static var sonicPrimary: Color { Color(light: Color(hex: "4648d4"), dark: Color(hex: "bd9dff")) }
    static var sonicPrimaryDim: Color { Color(light: Color(hex: "4648d4"), dark: Color(hex: "8a4cfc")) }
    static var sonicPrimaryContainer: Color { Color(light: Color(hex: "6063ee"), dark: Color(hex: "b28cff")) }
    static var sonicOnPrimary: Color { Color(light: .white, dark: .black) }
    static var sonicOnPrimaryFixed: Color { Color(light: Color(hex: "07006c"), dark: .black) }

    // Secondary
    static var sonicSecondary: Color { Color(light: Color(hex: "575992"), dark: Color(hex: "a28efc")) }
    static var sonicSecondaryContainer: Color { Color(light: Color(hex: "bdbefe"), dark: Color(hex: "49339d")) }

    // Tertiary
    static var sonicTertiary: Color { Color(light: Color(hex: "904900"), dark: Color(hex: "ffa5d9")) }
    static var sonicTertiaryContainer: Color { Color(light: Color(hex: "b55d00"), dark: Color(hex: "ff8ed2")) }

    // On-surface
    static var sonicOnSurface: Color { Color(light: Color(hex: "1a1c1c"), dark: .white) }
    static var sonicOnSurfaceVariant: Color { Color(light: Color(hex: "464554"), dark: Color(hex: "adaaab")) }

    // Outline
    static var sonicOutline: Color { Color(light: Color(hex: "767586"), dark: Color(hex: "767576")) }
    static var sonicOutlineVariant: Color { Color(light: Color(hex: "c7c4d7"), dark: Color(hex: "484849")) }

    // Error
    static var sonicError: Color { Color(light: Color(hex: "ba1a1a"), dark: Color(hex: "ff6e84")) }

    // Indigo accents (brand)
    static var sonicIndigo400: Color { Color(light: Color(hex: "4648d4"), dark: Color(hex: "818cf8")) }
    static var sonicIndigo500: Color { Color(light: Color(hex: "4648d4"), dark: Color(hex: "6366f1")) }

    // Glass tint for tab bar / mini player
    static var sonicGlassTint: Color { Color(light: .white, dark: Color(hex: "171717")) }
}

// MARK: - Gradients
extension Color {
    static var sonicPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [.sonicPrimary, .sonicPrimaryContainer],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Hex Color Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
