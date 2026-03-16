import CoreGraphics
import SwiftUI

struct DotmapTextStyle {
    let family: DotmapFontFamily
    let weight: DotmapFontWeight
    let size: CGFloat
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    let isItalic: Bool

    init(
        family: DotmapFontFamily,
        weight: DotmapFontWeight,
        size: CGFloat,
        lineHeight: CGFloat,
        letterSpacing: CGFloat,
        isItalic: Bool = false
    ) {
        self.family = family
        self.weight = weight
        self.size = size
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.isItalic = isItalic
    }

    fileprivate var lineSpacing: CGFloat {
        max(lineHeight - size, 0)
    }
}

private enum DotmapTracking {
    // Figma source uses -4% for Geist and 0% for mono styles.
    static func geist(for size: CGFloat) -> CGFloat { size * -0.04 }
    static let mono: CGFloat = 0
}

enum DotmapTypography {
    // 10px styles
    static let labelUppercase = DotmapTextStyle(
        family: .geistSans,
        weight: .medium,
        size: 10,
        lineHeight: 12,
        letterSpacing: DotmapTracking.geist(for: 10)
    )

    static let caption = DotmapTextStyle(
        family: .geistSans,
        weight: .medium,
        size: 10,
        lineHeight: 12,
        letterSpacing: DotmapTracking.geist(for: 10)
    )

    static let monoCaption = DotmapTextStyle(
        family: .geistMono,
        weight: .semibold,
        size: 10,
        lineHeight: 12,
        letterSpacing: DotmapTracking.mono
    )

    // 11px styles
    static let statusTitle = DotmapTextStyle(
        family: .geistSans,
        weight: .semibold,
        size: 11,
        lineHeight: 14,
        letterSpacing: DotmapTracking.geist(for: 11)
    )

    // 12px styles
    static let body = DotmapTextStyle(
        family: .geistSans,
        weight: .medium,
        size: 12,
        lineHeight: 15,
        letterSpacing: DotmapTracking.geist(for: 12)
    )

    static let bodyStrong = DotmapTextStyle(
        family: .geistSans,
        weight: .semibold,
        size: 12,
        lineHeight: 15,
        letterSpacing: DotmapTracking.geist(for: 12)
    )

    // 13px styles
    static let title = DotmapTextStyle(
        family: .geistSans,
        weight: .semibold,
        size: 13,
        lineHeight: 16,
        letterSpacing: DotmapTracking.geist(for: 13)
    )

    // Numeric accents
    static let metric = DotmapTextStyle(
        family: .geistMono,
        weight: .semibold,
        size: 15,
        lineHeight: 20,
        letterSpacing: DotmapTracking.mono
    )

    static let detailHeading = DotmapTextStyle(
        family: .geistMono,
        weight: .semibold,
        size: 20,
        lineHeight: 26,
        letterSpacing: DotmapTracking.mono
    )

    // Config editor and code snippets
    static let codeEditor = DotmapTextStyle(
        family: .geistMono,
        weight: .medium,
        size: 13,
        lineHeight: 18,
        letterSpacing: DotmapTracking.mono
    )

    static let codeEditorComment = DotmapTextStyle(
        family: .geistMono,
        weight: .medium,
        size: 13,
        lineHeight: 18,
        letterSpacing: DotmapTracking.mono,
        isItalic: true
    )
}

extension View {
    func dotmapTextStyle(_ style: DotmapTextStyle) -> some View {
        font(
            DotmapFonts.font(
                family: style.family,
                weight: style.weight,
                size: style.size,
                isItalic: style.isItalic
            )
        )
            .tracking(style.letterSpacing)
            .lineSpacing(style.lineSpacing)
    }
}
