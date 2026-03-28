import SwiftUI

// MARK: - Sonic Design System Colors
// Derived from the Stitch HTML exports and DESIGN.md
extension Color {
    // Core surfaces
    static let sonicBackground = Color(hex: "0e0e0f")
    static let sonicSurface = Color(hex: "0e0e0f")
    static let sonicSurfaceContainerLowest = Color(hex: "000000")
    static let sonicSurfaceContainerLow = Color(hex: "131314")
    static let sonicSurfaceContainer = Color(hex: "1a191b")
    static let sonicSurfaceContainerHigh = Color(hex: "201f21")
    static let sonicSurfaceContainerHighest = Color(hex: "262627")
    static let sonicSurfaceVariant = Color(hex: "262627")
    static let sonicSurfaceBright = Color(hex: "2c2c2d")

    // Primary
    static let sonicPrimary = Color(hex: "bd9dff")
    static let sonicPrimaryDim = Color(hex: "8a4cfc")
    static let sonicPrimaryContainer = Color(hex: "b28cff")
    static let sonicOnPrimary = Color(hex: "3c0089")
    static let sonicOnPrimaryFixed = Color(hex: "000000")

    // Secondary
    static let sonicSecondary = Color(hex: "a28efc")
    static let sonicSecondaryContainer = Color(hex: "49339d")

    // Tertiary
    static let sonicTertiary = Color(hex: "ffa5d9")
    static let sonicTertiaryContainer = Color(hex: "ff8ed2")

    // On-surface
    static let sonicOnSurface = Color.white
    static let sonicOnSurfaceVariant = Color(hex: "adaaab")

    // Outline
    static let sonicOutline = Color(hex: "767576")
    static let sonicOutlineVariant = Color(hex: "484849")

    // Error
    static let sonicError = Color(hex: "ff6e84")

    // Indigo accents (brand)
    static let sonicIndigo400 = Color(hex: "818cf8")
    static let sonicIndigo500 = Color(hex: "6366f1")

    // Gradients
    static var sonicPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [sonicPrimary, sonicPrimaryDim],
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
