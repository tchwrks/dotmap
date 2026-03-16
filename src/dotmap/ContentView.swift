//
//  ContentView.swift
//  dotmap
//
//  Created by Noah Davis on 3/15/26.
//

import SwiftUI

struct ContentView: View {
    private let previewIcons: [DotmapIcon] = [
        .home,
        .healthChecks,
        .aliases,
        .variables,
        .paths,
        .functions,
        .settings
    ]

    var body: some View {
        ZStack {
            DotmapColor.appBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: DotmapSpacing.lg) {
                Text("Dotmap")
                    .dotmapTextStyle(DotmapTypography.title)
                    .foregroundStyle(DotmapColor.textPrimary)

                Text("The visual shell config manager that macOS never shipped with")
                    .dotmapTextStyle(DotmapTypography.body)
                    .foregroundStyle(DotmapColor.textMuted)

                HStack(spacing: DotmapSpacing.sm) {
                    ForEach(previewIcons, id: \.self) { icon in
                        DotmapIconView(icon: icon, size: DotmapSpacing.s14, tint: DotmapColor.textSecondary)
                    }
                }
            }
            .padding(DotmapSpacing.xl)
            .frame(maxWidth: 560, alignment: .leading)
            .background(DotmapColor.surfacePrimary)
            .overlay(
                RoundedRectangle(cornerRadius: DotmapRadius.lg)
                    .stroke(DotmapColor.borderDefault, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.lg))
            .padding(DotmapSpacing.xl)
        }
    }
}

#Preview {
    ContentView()
}
