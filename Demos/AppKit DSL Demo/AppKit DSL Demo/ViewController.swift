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

class TabDSL: NSObject, DSFAppKitBuilderViewHandler {
	@objc dynamic var selectedTab: Int = 1 {
		didSet {
			Swift.print("Changed tabs - now \(selectedTab)")
		}
	}

	lazy var body: Element =
		TabView(tabViewType: .bottomTabsBezelBorder, selectedIndex: 2) {
			TabViewItem("first") {
				tab1
			}
			TabViewItem("second") {
				VStack { Label("second") }
			}
			TabViewItem("Third") {
				VStack { Label("third") }
			}
		}
		.bindTabIndex(self, keyPath: \TabDSL.selectedTab)

	lazy var tab1: Element =
		VStack {
			Label("first")
			Button(title: "goober!")
		}
}

class SplitDSL: NSObject, DSFAppKitBuilderViewHandler {
	@objc dynamic var hidden = NSSet()

	lazy var body: Element =
		Box("Split Testing") {
			VStack {
				HStack(alignment: .centerY) {
					Label("Click a segment to turn off the split item")
					Segmented(trackingMode: .selectAny) {
						Segment("first")
						Segment("second")
						Segment("third")
					}
					.bindSelectedSegments(self, keyPath: \SplitDSL.hidden)
				}

				SplitView {
					SplitViewItem(content: split1)
					SplitViewItem(content: split2)
					SplitViewItem(content: split3)
				}
				.bindHiddenViews(self, keyPath: \SplitDSL.hidden)
			}
			.edgeInsets(NSEdgeInsetsMake(8, 0, 0, 0))
		}
//		.additionalAppKitControlSettings { (box: NSBox) in
//			box.titleFont = NSFont.systemFont(ofSize: 18)
//		}

	lazy var split1: Element =
		VStack {
			Label("first").horizontalPriorities(hugging: 1)
			Label("item2").horizontalPriorities(hugging: 1)
		}
		.backgroundColor(.systemRed)
	lazy var split2: Element =
		VStack {
			Label("second")
				.horizontalPriorities(hugging: 10)
		}
		.backgroundColor(.systemGreen)
	lazy var split3: Element =
		VStack {
			Label("third")
				.horizontalPriorities(hugging: 10)
		}
		.backgroundColor(.systemBlue)
}
