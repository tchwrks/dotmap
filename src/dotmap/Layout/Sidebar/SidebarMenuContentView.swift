import SwiftUI

struct SidebarMenuContentView: View {
    @Binding var selectedRoute: AppRoute
    @Binding var hoveredRoute: AppRoute?
    let focusedRoute: FocusState<AppRoute?>.Binding
    @Binding var isKeyboardNavigationActive: Bool

    let configFiles: [ConfigFileItem]

    var body: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.xl) {
            Color.clear
                .frame(height: AppShellChromeMetrics.topChromeHeight)

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

            Spacer(minLength: DotmapSpacing.sm)

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DotmapSpacing.xs)
        .padding(.vertical, DotmapSpacing.sm)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .dotmapTextStyle(DotmapTypography.labelUppercase)
            .foregroundStyle(DotmapColor.textQuiet)
    }
}
