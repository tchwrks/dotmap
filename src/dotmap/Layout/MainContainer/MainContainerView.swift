//
//  MainContainerView.swift
//  dotmap
//
//  Created by Noah Davis on 3/16/26.
//
import SwiftUI

struct MainContainerView: View {
    let route: AppRoute
    let leadingTopAccessoryWidth: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            MainChromeView(
                title: route.title,
                leadingTopAccessoryWidth: leadingTopAccessoryWidth
            )
            routeContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DotmapColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: DotmapRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DotmapRadius.xl, style: .continuous)
                .stroke(DotmapColor.borderDefault, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var routeContent: some View {
        switch route {
        case .home:
            HomeView()
        case .healthChecks:
            placeholderScreen("Health Checks")
        case .aliases:
            placeholderScreen("Aliases")
        case .variables:
            placeholderScreen("Variables")
        case .paths:
            placeholderScreen("PATHs")
        case .functions:
            placeholderScreen("Functions")
        case let .config(selection):
            configPlaceholder(selection)
        case .settings:
            placeholderScreen("Settings")
        }
    }

    private func placeholderScreen(_ title: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotmapSpacing.sm) {
                Text("\(title) page")
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

    private func configPlaceholder(_ selection: ConfigSelection) -> some View {
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
