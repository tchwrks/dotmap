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
            HealthChecksView()
        case .aliases:
            AliasesView()
        case .variables:
            VariablesView()
        case .paths:
            PathsView()
        case .functions:
            FunctionsView()
        case let .config(selection):
            ConfigFileView(selection: selection)
        case .settings:
            SettingsView()
        }
    }
}
