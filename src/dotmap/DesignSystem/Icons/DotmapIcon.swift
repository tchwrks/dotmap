import AppKit
import SwiftUI

enum DotmapIcon: String, CaseIterable {
    case panelToggle
    case close
    case search
    case command

    case home
    case healthChecks
    case aliases
    case variables
    case paths
    case functions
    case configFile
    case settings

    case sectionHealthSummary
    case sectionRecentlyChanged
    case sectionEnvironment
    case sectionLoadOrder

    case performance
    case sources

    case checkCircle
    case chevronRight
    case chevronDown
    case chevronUp

    var assetName: String {
        "icon-\(rawValue)"
    }

    // Asset-first approach; SF Symbols are a fallback while icon export is in progress.
    var fallbackSystemName: String {
        switch self {
        case .panelToggle: "sidebar.left"
        case .close: "xmark"
        case .search: "magnifyingglass"
        case .command: "command"

        case .home: "house"
        case .healthChecks: "heart"
        case .aliases: "tag"
        case .variables: "slider.horizontal.3"
        case .paths: "link"
        case .functions: "curlybraces"
        case .configFile: "doc"
        case .settings: "gearshape"

        case .sectionHealthSummary: "heart.text.square"
        case .sectionRecentlyChanged: "clock.arrow.circlepath"
        case .sectionEnvironment: "desktopcomputer"
        case .sectionLoadOrder: "arrow.triangle.branch"

        case .performance: "speedometer"
        case .sources: "doc.text"

        case .checkCircle: "checkmark.circle"
        case .chevronRight: "chevron.right"
        case .chevronDown: "chevron.down"
        case .chevronUp: "chevron.up"
        }
    }
}

struct DotmapIconView: View {
    let icon: DotmapIcon
    var size: CGFloat = DotmapSpacing.s14
    var tint: Color = DotmapColor.textTertiary

    var body: some View {
        Group {
            if NSImage(named: NSImage.Name(icon.assetName)) != nil {
                Image(icon.assetName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
            } else {
                Image(systemName: icon.fallbackSystemName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(tint)
    }
}
