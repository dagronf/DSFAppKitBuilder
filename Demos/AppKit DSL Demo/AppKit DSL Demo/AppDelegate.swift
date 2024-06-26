//
//  AppDelegate.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 27/7/21.
//

import Cocoa

import DSFAppKitBuilder
import AppKitFocusOverlay

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	let focus = AppKitFocusOverlay()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		_ = focus

		// Uncomment the following line to show debugging output when debugging
		// DSFAppKitBuilderShowDebuggingOutput = true
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}

