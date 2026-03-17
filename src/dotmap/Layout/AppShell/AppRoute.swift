import Foundation

enum AppRoute: Hashable {
    case home
    case healthChecks
    case aliases
    case variables
    case paths
    case functions
    case config(ConfigSelection)
    case settings

    var title: String {
        screenTitle
    }

    var screenTitle: String {
        switch self {
        case .home:
            "Home"
        case .healthChecks:
            "Health Checks"
        case .aliases:
            "Environment / Aliases"
        case .variables:
            "Environment / Variables"
        case .paths:
            "Environment / PATHs"
        case .functions:
            "Environment / Functions"
        case let .config(selection):
            switch selection {
            case let .rootFile(fileName):
                "Configs / \(fileName)"
            case let .sourcedBlock(parent, block):
                "Configs / \(parent) • \(block)"
            }
        case .settings:
            "Settings"
        }
    }

    var sidebarTitle: String {
        switch self {
        case .home:
            "Home"
        case .healthChecks:
            "Health Checks"
        case .aliases:
            "Aliases"
        case .variables:
            "Variables"
        case .paths:
            "PATHs"
        case .functions:
            "Functions"
        case let .config(selection):
            switch selection {
            case let .rootFile(fileName):
                fileName
            case let .sourcedBlock(_, block):
                block
            }
        case .settings:
            "Settings"
        }
    }

    var contextualConfigParent: String? {
        switch self {
        case let .config(selection):
            switch selection {
            case let .rootFile(fileName):
                fileName
            case let .sourcedBlock(parent, _):
                parent
            }
        default:
            nil
        }
    }
}
