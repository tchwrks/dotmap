import AppKit
import SwiftUI

struct BehindWindowBlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.material = .sidebar
        effectView.blendingMode = .behindWindow
        effectView.state = .followsWindowActiveState
        effectView.isEmphasized = false
        effectView.appearance = NSAppearance(named: .vibrantDark)
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = .sidebar
        nsView.blendingMode = .behindWindow
        nsView.state = .followsWindowActiveState
        nsView.isEmphasized = false
        nsView.appearance = NSAppearance(named: .vibrantDark)
    }
}
