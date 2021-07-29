//
//  ViewController.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 27/7/21.
//

import Cocoa

import DSFAppKitBuilder

class ViewController: NSViewController {

	@IBOutlet var mainView: DSFAppKitBuilderView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.mainView.builder = MainTabs()
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}

class MainTabs: NSObject, DSFAppKitBuilderViewHandler {

	let primaryLayout = PrimaryDSL()
	let secondaryLayout = SecondaryDSL()
	let scrollTest = ScrollerTestDSL()
	let tabTest = TabDSL()
	let splitTest = SplitDSL()

	lazy var body: Element =
	TabView(selectedIndex: 0) {
		TabViewItem("Demo 1") { self.primaryLayout.body }
		TabViewItem("Demo 2") { self.secondaryLayout.body }
		TabViewItem("Demo 3") { self.scrollTest.body }
		TabViewItem("Demo 4") { self.tabTest.body }
		TabViewItem("Split Demo") { self.splitTest.body }
	}
}
