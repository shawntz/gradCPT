//
//  MetalViewController.swift
//  gradCPT
//
//  Created by Shawn Schwartz on 1/17/25.
//

import Cocoa
import MetalKit

// MARK: - Metal View Controller
class MetalViewController: NSViewController {
    var metalView: MTKView!
    var renderer: Renderer!
    var debugLabel: NSTextField!

    override func loadView() {
        let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 1512, height: 982))
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = .white
        view = mainView

        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }

        metalView = MTKView(frame: .zero, device: device)
        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.framebufferOnly = true
        metalView.preferredFramesPerSecond = 60

        view.addSubview(metalView)

        // Center the metal view with fixed size
        metalView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            metalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            metalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            metalView.widthAnchor.constraint(equalToConstant: 1024),
            metalView.heightAnchor.constraint(equalToConstant: 1024)
        ])

        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
    }
}
