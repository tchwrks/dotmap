import SwiftUI

struct SidebarToggleOverlayView: View {
    @Binding var isSidebarOpen: Bool

    let sidebarWidth: CGFloat
    let inset: CGFloat

    private let animation = Animation.spring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.12)

    var body: some View {
        Button {
            withAnimation(animation) {
                isSidebarOpen.toggle()
            }
        } label: {
            DotmapIconView(
                icon: isSidebarOpen ? .panelLeftClose : .panelLeftOpen,
                size: DotmapSpacing.s14,
                tint: DotmapColor.textTertiary
            )
                .frame(width: AppShellChromeMetrics.toggleSize, height: AppShellChromeMetrics.toggleSize)
                .background(
                    RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous)
                        .fill(DotmapColor.surfaceSecondary.opacity(0.75))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous)
                        .stroke(DotmapColor.borderStrong, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .offset(x: toggleX, y: AppShellChromeMetrics.toggleTopOffset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var toggleX: CGFloat {
        if isSidebarOpen {
            return inset + sidebarWidth - AppShellChromeMetrics.toggleSize - AppShellChromeMetrics.openToggleTrailingInsetFromSidebar
        }

        return AppShellChromeMetrics.toggleClosedX
    }
}
