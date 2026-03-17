import SwiftUI

// TODO: Replace mocked sidebar rows with production navigation/content.
struct SidebarMenuView: View {
    @Binding var selectedRoute: AppRoute

    var body: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.xl) {
            Color.clear
                .frame(height: AppShellChromeMetrics.topChromeHeight)

            VStack(alignment: .leading, spacing: DotmapSpacing.lg) {
                Text("Dotmap")
                    .dotmapTextStyle(DotmapTypography.title)
                    .foregroundStyle(DotmapColor.textSubdued)

                VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                    sidebarItem(icon: .home, title: "Home", route: .home)
                    sidebarItem(icon: .healthChecks, title: "Health Checks", route: .healthChecks)
                }
            }

            VStack(alignment: .leading, spacing: DotmapSpacing.md) {
                sectionLabel("Environment").textCase(.uppercase)
                VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                    sidebarItem(icon: .aliases, title: "Aliases", route: .aliases)
                    sidebarItem(icon: .variables, title: "Variables", route: .variables)
                    sidebarItem(icon: .paths, title: "PATHs", route: .paths)
                    sidebarItem(icon: .functions, title: "Functions", route: .functions)
                }
            }

            Spacer(minLength: DotmapSpacing.sm)

            sidebarItem(icon: .settings, title: "Settings", route: .settings)
        }
        .padding(.vertical, DotmapSpacing.sm)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .dotmapTextStyle(DotmapTypography.labelUppercase)
            .foregroundStyle(DotmapColor.textQuiet)
    }

    private func sidebarItem(icon: DotmapIcon, title: String, route: AppRoute) -> some View {
        let isActive = selectedRoute == route

        return Button {
            selectedRoute = route
        } label: {
            HStack(spacing: DotmapSpacing.xs) {
                DotmapIconView(icon: icon, size: DotmapSpacing.s18, tint: DotmapColor.textSecondary)
                Text(title)
                    .dotmapTextStyle(DotmapTypography.body)
                    .foregroundStyle(DotmapColor.textSecondary)
                Spacer(minLength: 0)
            }
            .padding(DotmapSpacing.xs)
            .background(isActive ? DotmapColor.selectionBackground : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
