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

    var body: some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
            ForEach(configFiles) { file in
                let isExpanded = isFileExpanded(file)

                VStack(alignment: .leading, spacing: DotmapSpacing.xs) {
                    ConfigFileTreeRow(
                        file: file,
                        isExpanded: isExpanded,
                        selectedRoute: $selectedRoute,
                        hoveredRoute: $hoveredRoute,
                        focusedRoute: focusedRoute,
                        isKeyboardNavigationActive: $isKeyboardNavigationActive,
                        onToggleExpand: {
                            toggleExpansion(for: file)
                        }
                    )

                    if file.hasChildren, isExpanded {
                        sourcedChildren(for: file)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func isFileExpanded(_ file: ConfigFileItem) -> Bool {
        manuallyExpandedFiles.contains(file.id) || selectedRoute.contextualConfigParent == file.name
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
