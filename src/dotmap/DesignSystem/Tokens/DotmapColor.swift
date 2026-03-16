import AppKit
import SwiftUI

enum DotmapColor {
    // App surfaces
    static let windowChrome = Color(nsColor: .dotmapHex(0x1E1E1E, alpha: 0.89))
    static let appBackground = Color(nsColor: .dotmapHex(0x181818))
    static let surfacePrimary = Color(nsColor: .dotmapHex(0x232323))
    static let surfaceSecondary = Color(nsColor: .dotmapHex(0x323232))
    static let surfaceTertiary = Color(nsColor: .dotmapHex(0x3C3C3C))
    static let fieldBackground = Color(nsColor: .dotmapHex(0x1E1E1E))
    static let selectionBackground = Color(nsColor: .dotmapHex(0x414141))
    static let overlayDim = Color(nsColor: .dotmapHex(0x000000, alpha: 0.38))

    // Borders
    static let borderDefault = Color(nsColor: .dotmapHex(0x323232))
    static let borderSubtle = Color(nsColor: .dotmapHex(0x363636))
    static let borderStrong = Color(nsColor: .dotmapHex(0x444444))
    static let borderField = Color(nsColor: .dotmapHex(0x2B2A2A))
    static let borderFocus = Color(nsColor: .dotmapHex(0x504D4D))

    // Text
    static let textPrimary = Color(nsColor: .dotmapHex(0xD0D0D0))
    static let textSecondary = Color(nsColor: .dotmapHex(0xAAAAAA))
    static let textTertiary = Color(nsColor: .dotmapHex(0x8A8A8A))
    static let textMuted = Color(nsColor: .dotmapHex(0x808080))
    static let textSubdued = Color(nsColor: .dotmapHex(0x737373))
    static let textQuiet = Color(nsColor: .dotmapHex(0x6B6B6B))
    static let textFaint = Color(nsColor: .dotmapHex(0x535353))
    static let textInverse = Color.white

    // Status
    static let critical = Color(nsColor: .dotmapHex(0xEE7676))
    static let criticalStrong = Color(nsColor: .dotmapHex(0xFF736A))
    static let warning = Color(nsColor: .dotmapHex(0xFEB93A))
    static let success = Color(nsColor: .dotmapHex(0x19C332))

    // Status surfaces
    static let criticalSurface = Color(nsColor: .dotmapHex(0x280C0C))
    static let criticalSurfaceBorder = Color(nsColor: .dotmapHex(0x5E0505))
    static let criticalSurfaceText = Color(nsColor: .dotmapHex(0xE57E6E))
}

private extension NSColor {
    static func dotmapHex(_ value: UInt32, alpha: CGFloat = 1.0) -> NSColor {
        let red = CGFloat((value >> 16) & 0xFF) / 255.0
        let green = CGFloat((value >> 8) & 0xFF) / 255.0
        let blue = CGFloat(value & 0xFF) / 255.0
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
