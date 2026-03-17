import SwiftUI

struct SidebarMenuContentView: View {
    @Binding var selectedRoute: AppRoute
    @Binding var hoveredRoute: AppRoute?
    let focusedRoute: FocusState<AppRoute?>.Binding
    @Binding var isKeyboardNavigationActive: Bool

    let configFiles: [ConfigFileItem]

    @State private var scrollViewportHeight: CGFloat = 0
    @State private var scrollContentFrame: CGRect = .zero

    private let scrollCoordinateSpaceName = "DotmapSidebarScrollRegion"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .frame(height: AppShellChromeMetrics.topChromeHeight)

            scrollableContent

            settingsRoute
                .padding(.horizontal, DotmapSpacing.xs)
                .padding(.top, DotmapSpacing.sm)
                .padding(.bottom, DotmapSpacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var scrollableContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotmapSpacing.xl) {
                primarySection
                environmentSection
                configSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DotmapSpacing.xs)
            .padding(.top, DotmapSpacing.sm)
            .padding(.bottom, DotmapSpacing.lg)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: SidebarScrollContentFramePreferenceKey.self,
                            value: proxy.frame(in: .named(scrollCoordinateSpaceName))
                        )
                }
            }
        }
        .scrollIndicators(.automatic)
        .coordinateSpace(name: scrollCoordinateSpaceName)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SidebarScrollViewportHeightPreferenceKey.self, value: proxy.size.height)
            }
        }
        .onPreferenceChange(SidebarScrollViewportHeightPreferenceKey.self) { value in
            scrollViewportHeight = value
        }
        .onPreferenceChange(SidebarScrollContentFramePreferenceKey.self) { value in
            scrollContentFrame = value
        }
        .overlay(alignment: .top) {
            if shouldShowTopFade {
                scrollEdgeFade(edge: .top)
            }
        }
        .overlay(alignment: .bottom) {
            if shouldShowBottomFade {
                scrollEdgeFade(edge: .bottom)
            }
        }
    }

    private var primarySection: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.lg) {
            Text("Dotmap")
                .dotmapTextStyle(DotmapTypography.title)
                .foregroundStyle(DotmapColor.textSubdued)

            VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                SidebarRouteItemView(
                    icon: .home,
                    title: AppRoute.home.sidebarTitle,
                    route: .home,
                    trailingCount: nil,
                    selectedRoute: $selectedRoute,
                    hoveredRoute: $hoveredRoute,
                    focusedRoute: focusedRoute,
                    isKeyboardNavigationActive: $isKeyboardNavigationActive
                )
                SidebarRouteItemView(
                    icon: .healthChecks,
                    title: AppRoute.healthChecks.sidebarTitle,
                    route: .healthChecks,
                    trailingCount: "3",
                    selectedRoute: $selectedRoute,
                    hoveredRoute: $hoveredRoute,
                    focusedRoute: focusedRoute,
                    isKeyboardNavigationActive: $isKeyboardNavigationActive
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.md) {
            sectionLabel("Environment").textCase(.uppercase)
            VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                SidebarRouteItemView(
                    icon: .aliases,
                    title: AppRoute.aliases.sidebarTitle,
                    route: .aliases,
                    trailingCount: "14",
                    selectedRoute: $selectedRoute,
                    hoveredRoute: $hoveredRoute,
                    focusedRoute: focusedRoute,
                    isKeyboardNavigationActive: $isKeyboardNavigationActive
                )
                SidebarRouteItemView(
                    icon: .variables,
                    title: AppRoute.variables.sidebarTitle,
                    route: .variables,
                    trailingCount: "14",
                    selectedRoute: $selectedRoute,
                    hoveredRoute: $hoveredRoute,
                    focusedRoute: focusedRoute,
                    isKeyboardNavigationActive: $isKeyboardNavigationActive
                )
                SidebarRouteItemView(
                    icon: .paths,
                    title: AppRoute.paths.sidebarTitle,
                    route: .paths,
                    trailingCount: "23",
                    selectedRoute: $selectedRoute,
                    hoveredRoute: $hoveredRoute,
                    focusedRoute: focusedRoute,
                    isKeyboardNavigationActive: $isKeyboardNavigationActive
                )
                SidebarRouteItemView(
                    icon: .functions,
                    title: AppRoute.functions.sidebarTitle,
                    route: .functions,
                    trailingCount: "9",
                    selectedRoute: $selectedRoute,
                    hoveredRoute: $hoveredRoute,
                    focusedRoute: focusedRoute,
                    isKeyboardNavigationActive: $isKeyboardNavigationActive
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var configSection: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.md) {
            sectionLabel("Configs").textCase(.uppercase)
            ConfigFileTree(
                configFiles: configFiles,
                selectedRoute: $selectedRoute,
                hoveredRoute: $hoveredRoute,
                focusedRoute: focusedRoute,
                isKeyboardNavigationActive: $isKeyboardNavigationActive
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var settingsRoute: some View {
        SidebarRouteItemView(
            icon: .settings,
            title: AppRoute.settings.sidebarTitle,
            route: .settings,
            trailingCount: nil,
            selectedRoute: $selectedRoute,
            hoveredRoute: $hoveredRoute,
            focusedRoute: focusedRoute,
            isKeyboardNavigationActive: $isKeyboardNavigationActive
        )
    }

    private enum ScrollFadeEdge {
        case top
        case bottom
    }

    private func scrollEdgeFade(edge: ScrollFadeEdge) -> some View {
        LinearGradient(
            colors: edge == .top
                ? [DotmapColor.windowChrome.opacity(0.5), DotmapColor.windowChrome.opacity(0.18), .clear]
                : [.clear, DotmapColor.windowChrome.opacity(0.18), DotmapColor.windowChrome.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: AppShellChromeMetrics.sidebarScrollFadeHeight)
        .allowsHitTesting(false)
    }

    private var isContentOverflowing: Bool {
        (scrollContentFrame.height - scrollViewportHeight) > 1
    }

    private var shouldShowTopFade: Bool {
        isContentOverflowing && scrollContentFrame.minY < -1
    }

    private var shouldShowBottomFade: Bool {
        isContentOverflowing && scrollContentFrame.maxY > (scrollViewportHeight + 1)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .dotmapTextStyle(DotmapTypography.labelUppercase)
            .foregroundStyle(DotmapColor.textQuiet)
    }
}

private struct SidebarScrollViewportHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct SidebarScrollContentFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
