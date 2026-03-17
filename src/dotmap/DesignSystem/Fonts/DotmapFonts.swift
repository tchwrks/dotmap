import AppKit
import CoreText
import Foundation
import SwiftUI

enum DotmapFontFamily {
    case geistSans
    case geistMono
}

enum DotmapFontWeight {
    case medium
    case semibold
}

enum DotmapFonts {
    private static var didRegister = false
    private static var registeredPostScriptNames = Set<String>()

    static func registerBundledFonts() {
        guard !didRegister else { return }
        didRegister = true

        // Support DesignSystem-local fonts plus legacy resource layouts.
        registerFonts(in: Bundle.main.resourceURL?.appendingPathComponent("DesignSystem/Fonts", isDirectory: true))
        registerFonts(in: Bundle.main.resourceURL?.appendingPathComponent("Fonts", isDirectory: true))
        registerFonts(in: Bundle.main.resourceURL?.appendingPathComponent("Resources/Fonts", isDirectory: true))
    }

    static func font(
        family: DotmapFontFamily,
        weight: DotmapFontWeight,
        size: CGFloat,
        isItalic: Bool = false
    ) -> Font {
        registerBundledFonts()

        if let postScriptName = resolvePostScriptName(family: family, weight: weight, isItalic: isItalic) {
            return .custom(postScriptName, size: size)
        }

        switch family {
        case .geistSans:
            return .system(size: size, weight: weight.swiftUIWeight)
        case .geistMono:
            return .system(size: size, weight: weight.swiftUIWeight, design: .monospaced)
        }
    }

    static func nsFont(
        family: DotmapFontFamily,
        weight: DotmapFontWeight,
        size: CGFloat,
        isItalic: Bool = false
    ) -> NSFont {
        registerBundledFonts()

        if let postScriptName = resolvePostScriptName(family: family, weight: weight, isItalic: isItalic),
           let customFont = NSFont(name: postScriptName, size: size) {
            return customFont
        }

        switch family {
        case .geistSans:
            return NSFont.systemFont(ofSize: size, weight: weight.nsFontWeight)
        case .geistMono:
            return NSFont.monospacedSystemFont(ofSize: size, weight: weight.nsFontWeight)
        }
    }

    private static func registerFonts(in directoryURL: URL?) {
        guard let directoryURL else { return }

        guard let enumerator = FileManager.default.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        for case let fileURL as URL in enumerator {
            let ext = fileURL.pathExtension.lowercased()
            guard ext == "ttf" || ext == "otf" else { continue }
            registerFont(at: fileURL)
        }
    }

    private static func registerFont(at fontURL: URL) {
        var registrationError: Unmanaged<CFError>?
        _ = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &registrationError)

        // Capture PostScript name so lookups are deterministic.
        guard let provider = CGDataProvider(url: fontURL as CFURL),
              let cgFont = CGFont(provider),
              let postScriptName = cgFont.postScriptName as String? else {
            return
        }

        registeredPostScriptNames.insert(postScriptName)
    }

    private static func resolvePostScriptName(
        family: DotmapFontFamily,
        weight: DotmapFontWeight,
        isItalic: Bool
    ) -> String? {
        let candidates = candidateNames(family: family, weight: weight, isItalic: isItalic)

        if let exactMatch = candidates.first(where: { registeredPostScriptNames.contains($0) }) {
            return exactMatch
        }

        if isItalic {
            let nonItalicCandidates = candidateNames(family: family, weight: weight, isItalic: false)
            if let nonItalicExact = nonItalicCandidates.first(where: { registeredPostScriptNames.contains($0) }) {
                return nonItalicExact
            }
        }

        return fuzzyPostScriptName(family: family, weight: weight, isItalic: isItalic)
            ?? (isItalic ? fuzzyPostScriptName(family: family, weight: weight, isItalic: false) : nil)
    }

    private static func candidateNames(
        family: DotmapFontFamily,
        weight: DotmapFontWeight,
        isItalic: Bool
    ) -> [String] {
        switch family {
        case .geistSans:
            switch weight {
            case .medium:
                if isItalic {
                    return [
                        "Geist-MediumItalic",
                        "GeistRoman-MediumItalic",
                        "Geist-MediumOblique"
                    ]
                }
                return [
                    "Geist-Medium",
                    "GeistRoman-Medium"
                ]

            case .semibold:
                if isItalic {
                    return [
                        "Geist-SemiBoldItalic",
                        "GeistRoman-SemiBoldItalic",
                        "Geist-SemiBoldOblique"
                    ]
                }
                return [
                    "Geist-SemiBold",
                    "GeistRoman-SemiBold"
                ]
            }

        case .geistMono:
            switch weight {
            case .medium:
                if isItalic {
                    return [
                        "GeistMono-MediumItalic",
                        "Geist Mono Medium Italic",
                        "GeistMono-Italic"
                    ]
                }
                return [
                    "GeistMono-Medium",
                    "Geist Mono Medium"
                ]

            case .semibold:
                if isItalic {
                    return [
                        "GeistMono-SemiBoldItalic",
                        "Geist Mono SemiBold Italic"
                    ]
                }
                return [
                    "GeistMono-SemiBold",
                    "Geist Mono SemiBold"
                ]
            }
        }
    }

    private static func fuzzyPostScriptName(
        family: DotmapFontFamily,
        weight: DotmapFontWeight,
        isItalic: Bool
    ) -> String? {
        let familyToken: String
        switch family {
        case .geistSans:
            familyToken = "geist"
        case .geistMono:
            familyToken = "geistmono"
        }

        let weightToken: String
        switch weight {
        case .medium:
            weightToken = "medium"
        case .semibold:
            weightToken = "semibold"
        }

        let familyMatches = registeredPostScriptNames
            .filter { normalized($0).contains(familyToken) }
            .sorted()

        guard !familyMatches.isEmpty else { return nil }

        let weightedMatches = familyMatches.filter { normalized($0).contains(weightToken) }
        let italicWeightedMatches = weightedMatches.filter { normalized($0).contains("italic") }

        if isItalic, let italicWeightedMatch = italicWeightedMatches.first {
            return italicWeightedMatch
        }

        if let weightedMatch = weightedMatches.first {
            return weightedMatch
        }

        if isItalic, let italicFamilyMatch = familyMatches.first(where: { normalized($0).contains("italic") }) {
            return italicFamilyMatch
        }

        return familyMatches.first
    }

    private static func normalized(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
    }
}

private extension DotmapFontWeight {
    var swiftUIWeight: Font.Weight {
        switch self {
        case .medium: .medium
        case .semibold: .semibold
        }
    }

    var nsFontWeight: NSFont.Weight {
        switch self {
        case .medium: .medium
        case .semibold: .semibold
        }
    }
}
