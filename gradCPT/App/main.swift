//
//  main.swift
//  gradCPT
//
//  Created by Shawn Schwartz on 1/17/25.
//

import Cocoa

// MARK: - Main gradCPT App Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
