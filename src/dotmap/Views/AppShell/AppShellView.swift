import SwiftUI

struct AppShellView: View {
    @AppStorage("dotmap.chrome.sidebar.open") private var isSidebarOpen = true

    private let sidebarWidth: CGFloat = 150
    private let contentInset: CGFloat = 8

    var body: some View {
        ZStack(alignment: .topLeading) {
            BehindWindowBlurView()
                .ignoresSafeArea()

            DotmapColor.windowChrome
                .ignoresSafeArea()

            HStack(alignment: .top, spacing: isSidebarOpen ? contentInset : 0) {
                if isSidebarOpen {
                    SidebarChromeStubView()
                        .frame(width: sidebarWidth, alignment: .topLeading)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }

                MainChromeStubView()
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
                minimumSize: CGSize(width: 824, height: 646)
            )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea()
        .animation(.spring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.12), value: isSidebarOpen)
    }
}
