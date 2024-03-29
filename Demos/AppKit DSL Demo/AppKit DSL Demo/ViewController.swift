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

	let mainTabs = MainTabs()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.mainView.setHandler(mainTabs)
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
	let tertiaryLayout = TertiaryDSL()
	let scrollTest = ScrollerTestDSL()
	let tabTest = TabDSL()
	let splitTest = SplitDSL()
	let boxText = BoxDSL()
	let zStack = ZStackDSL()
	let windowView = WindowPopoverSheetDSL()
	let gridView = GridDSL()

	lazy var body: Element =
	TabView(selectedIndex: 0) {
		TabViewItem("Demo 1") { self.primaryLayout.body }
		TabViewItem("Demo 2") { self.secondaryLayout.body }
		TabViewItem("Demo 3") { self.tertiaryLayout.body }
		TabViewItem("Scroll") { self.scrollTest.body }
		TabViewItem("Tab") { self.tabTest.body }
		TabViewItem("Split") { self.splitTest.body }
		TabViewItem("Box") { self.boxText.body }
		TabViewItem("ZStack") { self.zStack.body }
		TabViewItem("Window") { self.windowView.body }
		TabViewItem("Grid") { self.gridView.body }
	}
}
