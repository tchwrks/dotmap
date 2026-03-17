//
//  dotmapApp.swift
//  dotmap
//
//  Created by Noah Davis on 3/15/26.
//

import SwiftUI

@main
struct dotmapApp: App {
    init() {
        DotmapFonts.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .frame(
                    minWidth: DotmapWindowConfigurator.defaultMinimumSize.width,
                    minHeight: DotmapWindowConfigurator.defaultMinimumSize.height
                )
        }
        .windowStyle(.hiddenTitleBar)
    }
}
