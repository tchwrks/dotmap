import CoreGraphics

enum AppShellChromeMetrics {
    static let contentInset: CGFloat = DotmapSpacing.sm
    static let sidebarWidth: CGFloat = 200
    static let interPaneSpacing: CGFloat = DotmapSpacing.sm

    static let topChromeHeight: CGFloat = 36
    static let topChromeHorizontalPadding: CGFloat = DotmapSpacing.lg

    static let trafficLightsLeftInset: CGFloat = 16
    static let trafficLightsSpacing: CGFloat = 7
    static let trafficLightsDiameter: CGFloat = 12
    static let trafficLightsOpticalOffsetY: CGFloat = -0.5

    static let toggleSize: CGFloat = 18
    static let toggleGapFromTrafficLights: CGFloat = DotmapSpacing.xxl
    static let toggleGapToTitle: CGFloat = DotmapSpacing.xxl
    static let openToggleTrailingInsetFromSidebar: CGFloat = DotmapSpacing.sm
    static let keyboardFocusRingLineWidth: CGFloat = 2

    static var topChromeCenterYFromTop: CGFloat {
        contentInset + (topChromeHeight / 2)
    }

    static var trafficLightsTopInset: CGFloat {
        topChromeCenterYFromTop - (trafficLightsDiameter / 2) + trafficLightsOpticalOffsetY
    }

    static var toggleTopOffset: CGFloat {
        topChromeCenterYFromTop - (toggleSize / 2)
    }

    static var trafficLightsClusterWidth: CGFloat {
        (trafficLightsDiameter * 3) + (trafficLightsSpacing * 2)
    }

    static var toggleClosedX: CGFloat {
        contentInset + trafficLightsLeftInset + trafficLightsClusterWidth + toggleGapFromTrafficLights
    }

    static var closedTopChromeLeadingAccessoryWidth: CGFloat {
        let baseLeadingX = contentInset + topChromeHorizontalPadding
        let toggleRight = toggleClosedX + toggleSize
        return max(0, (toggleRight + toggleGapToTitle) - baseLeadingX)
    }
}
