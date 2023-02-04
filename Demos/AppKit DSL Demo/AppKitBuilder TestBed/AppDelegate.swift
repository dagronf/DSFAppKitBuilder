//
//  AppDelegate.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Cocoa
import DSFAppKitBuilder

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	


	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		DSFAppKitBuilderShowDebuggingOutput = true
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}


}

