import AppKit
import SwiftUI

struct DotmapWindowConfigurator: NSViewRepresentable {
    let minimumSize: CGSize

    func makeCoordinator() -> Coordinator {
        Coordinator(minimumSize: minimumSize)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)

        DispatchQueue.main.async {
            context.coordinator.configureIfNeeded(for: view.window)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.minimumSize = minimumSize

        DispatchQueue.main.async {
            context.coordinator.configureIfNeeded(for: nsView.window)
        }
    }

    final class Coordinator {
        var minimumSize: CGSize

        private weak var observedWindow: NSWindow?
        private var didConfigure = false
        private var resizeObserver: NSObjectProtocol?

        init(minimumSize: CGSize) {
            self.minimumSize = minimumSize
        }

        deinit {
            if let resizeObserver {
                NotificationCenter.default.removeObserver(resizeObserver)
            }
        }

        func configureIfNeeded(for window: NSWindow?) {
            guard let window else { return }

            if observedWindow !== window {
                if let resizeObserver {
                    NotificationCenter.default.removeObserver(resizeObserver)
                }

                observedWindow = window
                resizeObserver = NotificationCenter.default.addObserver(
                    forName: NSWindow.didResizeNotification,
                    object: window,
                    queue: .main
                ) { [weak self] _ in
                    self?.positionWindowButtons(in: window)
                }
            }

            applyWindowStyle(on: window)
            positionWindowButtons(in: window)
            didConfigure = true
        }

        private func applyWindowStyle(on window: NSWindow) {
            if !didConfigure {
                window.styleMask.insert(.fullSizeContentView)
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
            }

            window.isOpaque = false
            window.backgroundColor = .clear
            window.contentView?.wantsLayer = true
            window.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

            if #available(macOS 11.0, *) {
                window.titlebarSeparatorStyle = .none
            }

            window.minSize = NSSize(width: minimumSize.width, height: minimumSize.height)
        }

        private func positionWindowButtons(in window: NSWindow) {
            guard
                let closeButton = window.standardWindowButton(.closeButton),
                let minimizeButton = window.standardWindowButton(.miniaturizeButton),
                let zoomButton = window.standardWindowButton(.zoomButton),
                let buttonContainer = closeButton.superview
            else {
                return
            }

            let leftInset: CGFloat = 16
            let spacing: CGFloat = 7
            let topInset: CGFloat = 11
            let y = buttonContainer.bounds.height - closeButton.frame.height - topInset

            closeButton.setFrameOrigin(NSPoint(x: leftInset, y: y))
            minimizeButton.setFrameOrigin(NSPoint(x: closeButton.frame.maxX + spacing, y: y))
            zoomButton.setFrameOrigin(NSPoint(x: minimizeButton.frame.maxX + spacing, y: y))
        }
    }
}
