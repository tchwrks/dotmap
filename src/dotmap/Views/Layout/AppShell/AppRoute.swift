import Foundation

enum AppRoute: Hashable {
    case home
    case healthChecks
    case aliases
    case variables
    case paths
    case functions
    case settings

    var title: String {
        switch self {
        case .home:
            "Home"
        case .healthChecks:
            "Health Checks"
        case .aliases:
            "Environment: Aliases"
        case .variables:
            "Environment: Variables"
        case .paths:
            "Environment: PATHs"
        case .functions:
            "Environment: Functions"
        case .settings:
            "Settings"
        }
    }
}
