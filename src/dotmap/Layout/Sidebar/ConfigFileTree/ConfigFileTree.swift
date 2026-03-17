//
//  ConfigFileTree.swift
//  dotmap
//
//  Created by Noah Davis on 3/16/26.
//

import SwiftUI

struct ConfigFileTree: View {
    let configFiles: [ConfigFileItem]

    @Binding var selectedRoute: AppRoute
    @Binding var hoveredRoute: AppRoute?
    let focusedRoute: FocusState<AppRoute?>.Binding
    @Binding var isKeyboardNavigationActive: Bool

    @State private var manuallyExpandedFiles = Set<String>()
    @State private var isShowingAllFiles = false
    @FocusState private var isShowMoreToggleFocused: Bool

    private let defaultVisibleRootRows = 10

    var body: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
            ForEach(visibleConfigFiles) { file in
                let isExpanded = isFileExpanded(file)

                VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                    ConfigFileTreeRow(
                        file: file,
                        isExpanded: isExpanded,
                        selectedRoute: $selectedRoute,
                        hoveredRoute: $hoveredRoute,
                        focusedRoute: focusedRoute,
                        isKeyboardNavigationActive: $isKeyboardNavigationActive,
                        onSelect: {
                            selectFile(file)
                        },
                        onToggleExpand: {
                            toggleExpansion(for: file)
                        }
                    )

                    if file.hasChildren, isExpanded {
                        sourcedChildren(for: file)
                    }
                }
            }

            if shouldShowFileLimitToggle {
                showMoreToggle
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var visibleConfigFiles: [ConfigFileItem] {
        guard !isShowingAllFiles else { return configFiles }
        return Array(configFiles.prefix(defaultVisibleRootRows))
    }

    private var shouldShowFileLimitToggle: Bool {
        configFiles.count > defaultVisibleRootRows
    }

    private var showMoreToggle: some View {
        let shouldShowKeyboardFocusRing = isKeyboardNavigationActive && isShowMoreToggleFocused

        return Button {
            isKeyboardNavigationActive = false
            isShowingAllFiles.toggle()
        } label: {
            Text(isShowingAllFiles ? "Show less" : "Show more")
                .dotmapTextStyle(DotmapTypography.body)
                .foregroundStyle(DotmapColor.textSubdued)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DotmapSpacing.xs)
                .padding(.vertical, DotmapSpacing.xs)
                .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous))
                .contentShape(Rectangle())
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
        .focused($isShowMoreToggleFocused)
        .focusEffectDisabled()
        .onKeyPress(.return) {
            isKeyboardNavigationActive = true
            isShowingAllFiles.toggle()
            return .handled
        }
        .onKeyPress(.space) {
            isKeyboardNavigationActive = true
            isShowingAllFiles.toggle()
            return .handled
        }
        .accessibilityLabel(Text(isShowingAllFiles ? "Show fewer config files" : "Show all config files"))
    }

    private func isFileExpanded(_ file: ConfigFileItem) -> Bool {
        manuallyExpandedFiles.contains(file.id) || selectedRoute.contextualConfigParent == file.name
    }

    private func selectFile(_ file: ConfigFileItem) {
        selectedRoute = .config(.rootFile(file.name))
        if file.hasChildren {
            manuallyExpandedFiles.insert(file.id)
        }
    }

    private func toggleExpansion(for file: ConfigFileItem) {
        if manuallyExpandedFiles.contains(file.id) {
            manuallyExpandedFiles.remove(file.id)
        } else {
            manuallyExpandedFiles.insert(file.id)
        }
    }

    private func sourcedChildren(for file: ConfigFileItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(file.children) { child in
                SourcedFileRow(name: child.name)
            }
        }
        .padding(.leading, DotmapSpacing.xs)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(DotmapColor.textSubdued)
                .frame(width: 1)
        }
        .padding(.leading, DotmapSpacing.s11)
    }
}
