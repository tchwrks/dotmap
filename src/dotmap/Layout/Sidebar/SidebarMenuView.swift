import AppKit
import SwiftUI

struct SidebarMenuView: View {
    @Binding var selectedRoute: AppRoute

    @State private var hoveredRoute: AppRoute?
    @FocusState private var focusedRoute: AppRoute?
    @State private var isKeyboardNavigationActive = false
    @State private var keyDownMonitor: Any?
    @State private var mouseDownMonitor: Any?

    var body: some View {
        SidebarMenuContentView(
            selectedRoute: $selectedRoute,
            hoveredRoute: $hoveredRoute,
            focusedRoute: $focusedRoute,
            isKeyboardNavigationActive: $isKeyboardNavigationActive,
            configFiles: mockConfigs
        )
        .onAppear(perform: installInputModeMonitors)
        .onDisappear(perform: removeInputModeMonitors)
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
