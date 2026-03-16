import SwiftUI

struct SidebarToggleOverlayView: View {
    @Binding var isSidebarOpen: Bool

    let sidebarWidth: CGFloat
    let inset: CGFloat

    private let buttonSize: CGFloat = 18
    private let topOffset: CGFloat = 8
    private let closedX: CGFloat = 90

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.12)) {
                isSidebarOpen.toggle()
            }
        } label: {
            DotmapIconView(icon: .panelToggle, size: DotmapSpacing.s14, tint: DotmapColor.textTertiary)
                .frame(width: buttonSize, height: buttonSize)
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
        .offset(x: toggleX, y: topOffset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var toggleX: CGFloat {
        let openX = inset + sidebarWidth - buttonSize
        return isSidebarOpen ? openX : closedX
    }
}
