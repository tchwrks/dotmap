import SwiftUI

struct AppShellView: View {
    @AppStorage("dotmap.chrome.sidebar.open") private var isSidebarOpen = true

    private let sidebarWidth = AppShellChromeMetrics.sidebarWidth
    private let contentInset = AppShellChromeMetrics.contentInset

    var body: some View {
        ZStack(alignment: .topLeading) {
            BehindWindowBlurView()
                .ignoresSafeArea()

            DotmapColor.windowChrome
                .ignoresSafeArea()

            HStack(alignment: .top, spacing: isSidebarOpen ? AppShellChromeMetrics.interPaneSpacing : 0) {
                if isSidebarOpen {
                    SidebarMenuView()
                        .frame(width: sidebarWidth, alignment: .topLeading)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }

                MainChromeView()
                    .leadingTopAccessoryWidth(isSidebarOpen ? 0 : AppShellChromeMetrics.closedTopChromeLeadingAccessoryWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(contentInset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            SidebarToggleOverlayView(
                isSidebarOpen: $isSidebarOpen,
                sidebarWidth: sidebarWidth,
                inset: contentInset
            )
        }
        .background(
            DotmapWindowConfigurator(
                controlsLeftInset: AppShellChromeMetrics.trafficLightsLeftInset,
                controlsSpacing: AppShellChromeMetrics.trafficLightsSpacing,
                controlsTopInset: AppShellChromeMetrics.trafficLightsTopInset
            )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea()
        .animation(.spring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.12), value: isSidebarOpen)
    }
}
