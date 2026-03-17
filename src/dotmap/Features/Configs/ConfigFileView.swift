//
//  ConfigFileView.swift
//  dotmap
//
//  Created by Noah Davis on 3/17/26.
//

import SwiftUI

struct ConfigFileView: View {
    let selection: ConfigSelection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
                switch selection {
                case let .rootFile(fileName):
                    Text("\(fileName) config")
                        .dotmapTextStyle(DotmapTypography.bodyStrong)
                        .foregroundStyle(DotmapColor.textPrimary)
                    Text("Config page placeholder content")
                        .dotmapTextStyle(DotmapTypography.body)
                        .foregroundStyle(DotmapColor.textMuted)
                case let .sourcedBlock(parent, block):
                    Text("\(parent): \(block)")
                        .dotmapTextStyle(DotmapTypography.bodyStrong)
                        .foregroundStyle(DotmapColor.textPrimary)
                    Text("Sourced block placeholder content")
                        .dotmapTextStyle(DotmapTypography.body)
                        .foregroundStyle(DotmapColor.textMuted)
                }
            }
            .frame(maxWidth: 800, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(DotmapSpacing.lg)
            .padding(.top, DotmapSpacing.sm)
        }
        .scrollIndicators(.never)
    }
}
