//
//  ViewController.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 27/7/21.
//

import Cocoa

import DSFAppKitBuilder

class ViewController: NSViewController {

	@IBOutlet weak var demo1View: DSFAppKitBuilderView!
	@IBOutlet weak var demo2View: DSFAppKitBuilderView!
	@IBOutlet weak var demo3View: DSFAppKitBuilderView!
	@IBOutlet weak var demo4View: DSFAppKitBuilderView!

	let primaryLayout = PrimaryDSL()
	let secondaryLayout = SecondaryDSL()
	let scrollTest = ScrollerTestDSL()

	let tabTest = TabDSL()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		demo1View.builder = primaryLayout
		demo2View.builder = secondaryLayout
		demo3View.builder = scrollTest
		demo4View.builder = tabTest
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}


class TabDSL: NSObject, DSFAppKitBuilderViewHandler {

	@objc dynamic var selectedTab: Int = 1 {
		didSet {
			Swift.print("Changed tabs - now \(selectedTab)")
		}
	}

	lazy var body: Element =
		TabView(tabViewType: .bottomTabsBezelBorder, selectedIndex: 2) {
			Tab("first", content: tab1)
			Tab("second", content: Label("second"))
			Tab("Third", content: Label("third"))
		}
		.bindTabIndex(self, keyPath: \TabDSL.selectedTab)

	lazy var tab1: Element =
	VStack {
		Label("first")
		Button(title: "goober!")
	}

}
