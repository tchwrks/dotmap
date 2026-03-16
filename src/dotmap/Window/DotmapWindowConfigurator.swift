import AppKit
import SwiftUI

struct DotmapWindowConfigurator: NSViewRepresentable {
    let minimumSize: CGSize
    let controlsLeftInset: CGFloat
    let controlsSpacing: CGFloat
    let controlsTopInset: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(
            minimumSize: minimumSize,
            controlsLeftInset: controlsLeftInset,
            controlsSpacing: controlsSpacing,
            controlsTopInset: controlsTopInset
        )
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
        context.coordinator.controlsLeftInset = controlsLeftInset
        context.coordinator.controlsSpacing = controlsSpacing
        context.coordinator.controlsTopInset = controlsTopInset

        DispatchQueue.main.async {
            context.coordinator.configureIfNeeded(for: nsView.window)
        }
    }

    final class Coordinator {
        var minimumSize: CGSize
        var controlsLeftInset: CGFloat
        var controlsSpacing: CGFloat
        var controlsTopInset: CGFloat

        private weak var observedWindow: NSWindow?
        private var didConfigure = false
        private var resizeObserver: NSObjectProtocol?

        init(
            minimumSize: CGSize,
            controlsLeftInset: CGFloat,
            controlsSpacing: CGFloat,
            controlsTopInset: CGFloat
        ) {
            self.minimumSize = minimumSize
            self.controlsLeftInset = controlsLeftInset
            self.controlsSpacing = controlsSpacing
            self.controlsTopInset = controlsTopInset
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

            let y = buttonContainer.bounds.height - closeButton.frame.height - controlsTopInset

            closeButton.setFrameOrigin(NSPoint(x: controlsLeftInset, y: y))
            minimizeButton.setFrameOrigin(NSPoint(x: closeButton.frame.maxX + controlsSpacing, y: y))
            zoomButton.setFrameOrigin(NSPoint(x: minimizeButton.frame.maxX + controlsSpacing, y: y))
        }
    }
}
