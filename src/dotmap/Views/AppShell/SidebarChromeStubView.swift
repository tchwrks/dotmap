import SwiftUI

struct SidebarChromeStubView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.xl) {
            Color.clear
                .frame(height: AppShellChromeMetrics.topChromeHeight)

            VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
                Text("Dotmap")
                    .dotmapTextStyle(DotmapTypography.title)
                    .foregroundStyle(DotmapColor.textSubdued)

                VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                    sidebarItem(icon: .home, title: "Home", isActive: true)
                    sidebarItem(icon: .healthChecks, title: "Health Checks", isActive: false)
                }
            }

            VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
                sectionLabel("Environment")
                VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                    sidebarItem(icon: .aliases, title: "Aliases", isActive: false)
                    sidebarItem(icon: .variables, title: "Variables", isActive: false)
                    sidebarItem(icon: .paths, title: "PATHS", isActive: false)
                    sidebarItem(icon: .functions, title: "Functions", isActive: false)
                }
            }

            Spacer(minLength: DotmapSpacing.sm)

            sidebarItem(icon: .settings, title: "Settings", isActive: false)
        }
        .padding(.vertical, DotmapSpacing.sm)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .dotmapTextStyle(DotmapTypography.labelUppercase)
            .foregroundStyle(DotmapColor.textQuiet)
    }

    private func sidebarItem(icon: DotmapIcon, title: String, isActive: Bool) -> some View {
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
}
