//
//  AppDelegate.swift
//  gradCPT
//
//  Created by Shawn Schwartz on 1/17/25.
//

import Cocoa
import MetalKit

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let screen = NSScreen.main!
        let frame = screen.frame
        let contentView = NSView(frame: frame)
        
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = .white

        window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .borderless],
            backing: .buffered,
            defer: false
        )
        window.title = "gradCPT"
        window.level = .mainMenu
        window.backgroundColor = .white
        window.isMovable = true
        window.collectionBehavior = [.fullScreenPrimary, .stationary]
        window.contentView = contentView
        window.contentViewController = MetalViewController()
        window.makeKeyAndOrderFront(nil)
        window.center()
    }
}
