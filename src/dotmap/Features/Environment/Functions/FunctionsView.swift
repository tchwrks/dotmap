//
//  FunctionsView.swift
//  dotmap
//
//  Created by Noah Davis on 3/17/26.
//

import SwiftUI

struct FunctionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
                Text("Functions page")
                    .dotmapTextStyle(DotmapTypography.bodyStrong)
                    .foregroundStyle(DotmapColor.textPrimary)
                Text("Placeholder content")
                    .dotmapTextStyle(DotmapTypography.body)
                    .foregroundStyle(DotmapColor.textMuted)
            }
            .frame(maxWidth: 800, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(DotmapSpacing.lg)
            .padding(.top, DotmapSpacing.sm)
        }
        .scrollIndicators(.never)
    }
}
