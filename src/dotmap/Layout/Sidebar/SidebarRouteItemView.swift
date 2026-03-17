import SwiftUI

struct SidebarRouteItemView: View {
    let icon: DotmapIcon
    let title: String
    let route: AppRoute
    let trailingCount: String?

    @Binding var selectedRoute: AppRoute
    @Binding var hoveredRoute: AppRoute?
    let focusedRoute: FocusState<AppRoute?>.Binding
    @Binding var isKeyboardNavigationActive: Bool

    var body: some View {
        let isActive = selectedRoute == route
        let isHovered = hoveredRoute == route
        let shouldShowKeyboardFocusRing = isKeyboardNavigationActive && focusedRoute.wrappedValue == route

        return Button {
            isKeyboardNavigationActive = false
            selectedRoute = route
        } label: {
            HStack(spacing: DotmapSpacing.xs) {
                HStack(spacing: DotmapSpacing.xs) {
                    DotmapIconView(
                        icon: icon,
                        size: DotmapSpacing.s18,
                        tint: isActive ? DotmapColor.textPrimary : DotmapColor.textSecondary
                    )
                    Text(title)
                        .dotmapTextStyle(DotmapTypography.body)
                        .foregroundStyle(isActive ? DotmapColor.textPrimary : DotmapColor.textSecondary)
                }

                Spacer(minLength: 0)

                if let trailingCount {
                    Text(trailingCount)
                        .dotmapTextStyle(DotmapTypography.caption)
                        .foregroundStyle(DotmapColor.textSubdued)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DotmapSpacing.xs)
            .padding(.vertical, DotmapSpacing.xs)
            .background(rowBackgroundColor(isActive: isActive, isHovered: isHovered))
            .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous))
            .overlay {
                if shouldShowKeyboardFocusRing {
                    RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous)
                        .stroke(
                            DotmapColor.keyboardFocusRing,
                            lineWidth: AppShellChromeMetrics.keyboardFocusRingLineWidth
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .focusable(true)
        .focused(focusedRoute, equals: route)
        .focusEffectDisabled()
        .onKeyPress(.return) {
            isKeyboardNavigationActive = true
            selectedRoute = route
            return .handled
        }
        .onKeyPress(.space) {
            isKeyboardNavigationActive = true
            selectedRoute = route
            return .handled
        }
        .onHover { isHovering in
            if isHovering {
                hoveredRoute = route
            } else if hoveredRoute == route {
                hoveredRoute = nil
            }
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Navigate to \(title)"))
        .accessibilityValue(Text(isActive ? "Current page" : ""))
    }

    private func rowBackgroundColor(isActive: Bool, isHovered: Bool) -> Color {
        if isActive {
            return DotmapColor.selectionBackground
        }
        if isHovered {
            return DotmapColor.selectionBackground.opacity(0.7)
        }
        return .clear
    }
}
