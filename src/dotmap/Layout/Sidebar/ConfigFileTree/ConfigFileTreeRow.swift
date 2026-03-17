//
//  ConfigFileTreeRow.swift
//  dotmap
//
//  Created by Noah Davis on 3/16/26.
//

import SwiftUI

struct ConfigFileTreeRow: View {
    let file: ConfigFileItem
    let isExpanded: Bool

    @Binding var selectedRoute: AppRoute
    @Binding var hoveredRoute: AppRoute?
    let focusedRoute: FocusState<AppRoute?>.Binding
    @Binding var isKeyboardNavigationActive: Bool

    let onSelect: () -> Void
    let onToggleExpand: () -> Void

    private var route: AppRoute {
        .config(.rootFile(file.name))
    }

    var body: some View {
        let isActive = selectedRoute == route
        let isHovered = hoveredRoute == route
        let shouldShowKeyboardFocusRing = isKeyboardNavigationActive && focusedRoute.wrappedValue == route

        return ZStack(alignment: .trailing) {
            Button {
                isKeyboardNavigationActive = false
                onSelect()
            } label: {
                HStack(spacing: DotmapSpacing.xs) {
                    DotmapIconView(
                        icon: .configFile,
                        size: DotmapSpacing.s18,
                        tint: isActive ? DotmapColor.textPrimary : DotmapColor.textSecondary
                    )
                    Text(route.sidebarTitle)
                        .dotmapTextStyle(DotmapTypography.body)
                        .foregroundStyle(isActive ? DotmapColor.textPrimary : DotmapColor.textSecondary)
                    Spacer(minLength: 0)

                    if file.hasChildren {
                        Color.clear
                            .frame(width: DotmapSpacing.s18, height: DotmapSpacing.s18)
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
                onSelect()
                return .handled
            }
            .onKeyPress(.space) {
                isKeyboardNavigationActive = true
                onSelect()
                return .handled
            }
            .accessibilityLabel(Text(file.name))
            .accessibilityHint(Text("Open config file"))
            .accessibilityValue(Text(isActive ? "Current page" : ""))
            .frame(maxWidth: .infinity, alignment: .leading)

            if file.hasChildren {
                Button {
                    isKeyboardNavigationActive = false
                    onToggleExpand()
                } label: {
                    DotmapIconView(
                        icon: .configCaret,
                        size: 12,
                        tint: DotmapColor.textSubdued
                    )
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .frame(width: DotmapSpacing.s18, height: DotmapSpacing.s18)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .accessibilityLabel(Text(isExpanded ? "Collapse \(file.name)" : "Expand \(file.name)"))
                .padding(.trailing, DotmapSpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onHover { isHovering in
            if isHovering {
                hoveredRoute = route
            } else if hoveredRoute == route {
                hoveredRoute = nil
            }
        }
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
