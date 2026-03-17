import AppKit
import SwiftUI

struct SidebarToggleOverlayView: View {
    @Binding var isSidebarOpen: Bool

    @FocusState private var isToggleFocused: Bool
    @State private var isKeyboardNavigationActive = false
    @State private var keyDownMonitor: Any?
    @State private var mouseDownMonitor: Any?

    let sidebarWidth: CGFloat
    let inset: CGFloat

    private let animation = Animation.spring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.12)

    var body: some View {
        Button {
            isKeyboardNavigationActive = false
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
                .overlay {
                    if shouldShowKeyboardFocusRing {
                        RoundedRectangle(cornerRadius: DotmapRadius.sm, style: .continuous)
                            .stroke(
                                DotmapColor.keyboardFocusRing,
                                lineWidth: AppShellChromeMetrics.keyboardFocusRingLineWidth
                            )
                    }
                }
        }
        .buttonStyle(.plain)
        .focusable(true)
        .focused($isToggleFocused)
        .focusEffectDisabled()
        .onKeyPress(.return) {
            isKeyboardNavigationActive = true
            withAnimation(animation) {
                isSidebarOpen.toggle()
            }
            return .handled
        }
        .onKeyPress(.space) {
            isKeyboardNavigationActive = true
            withAnimation(animation) {
                isSidebarOpen.toggle()
            }
            return .handled
        }
        .accessibilityLabel(Text(isSidebarOpen ? "Close sidebar" : "Open sidebar"))
        .accessibilityHint(Text("Toggle sidebar"))
        .contentShape(Rectangle())
        .offset(x: toggleX, y: AppShellChromeMetrics.toggleTopOffset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear(perform: installInputModeMonitors)
        .onDisappear(perform: removeInputModeMonitors)
    }

    private var toggleX: CGFloat {
        if isSidebarOpen {
            return inset + sidebarWidth - AppShellChromeMetrics.toggleSize - AppShellChromeMetrics.openToggleTrailingInsetFromSidebar
        }

        return AppShellChromeMetrics.toggleClosedX
    }

    private var shouldShowKeyboardFocusRing: Bool {
        isKeyboardNavigationActive && isToggleFocused
    }

    private func installInputModeMonitors() {
        if keyDownMonitor == nil {
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                if keyboardNavigationKeyCodes.contains(event.keyCode) {
                    isKeyboardNavigationActive = true
                }
                return event
            }
        }

        if mouseDownMonitor == nil {
            mouseDownMonitor = NSEvent.addLocalMonitorForEvents(
                matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
            ) { event in
                isKeyboardNavigationActive = false
                return event
            }
        }
    }

    private func removeInputModeMonitors() {
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }
        if let mouseDownMonitor {
            NSEvent.removeMonitor(mouseDownMonitor)
            self.mouseDownMonitor = nil
        }
    }

    private var keyboardNavigationKeyCodes: Set<UInt16> {
        // tab, return, enter, space, arrows
        [48, 36, 76, 49, 123, 124, 125, 126]
    }
}
