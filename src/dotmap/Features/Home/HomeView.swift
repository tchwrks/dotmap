//
//  HomeView.swift
//  dotmap
//
//  Created by Noah Davis on 3/16/26.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotmapSpacing.lg) {
                stubBlock(title: "Shell Layout Stub")
                stubBlock(title: "Main Content Stub")
                stubBlock(title: "Detail Surfaces Stub")
            }
            .frame(maxWidth: 800, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(DotmapSpacing.lg)
            .padding(.top, DotmapSpacing.sm)
        }
        .scrollIndicators(.never)
    }

    private func stubBlock(title: String) -> some View {
        VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
            Text(title)
                .dotmapTextStyle(DotmapTypography.bodyStrong)
                .foregroundStyle(DotmapColor.textPrimary)

            RoundedRectangle(cornerRadius: DotmapRadius.lg, style: .continuous)
                .fill(DotmapColor.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: DotmapRadius.lg, style: .continuous)
                        .stroke(DotmapColor.borderDefault, lineWidth: 1)
                )
                .frame(height: 124)
        }
    }
}
