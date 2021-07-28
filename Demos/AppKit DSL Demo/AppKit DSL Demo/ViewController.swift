//
//  ViewController.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 27/7/21.
//

import Cocoa

import DSFAppKitBuilder

class ViewController: NSViewController {
	@IBOutlet var demo1View: DSFAppKitBuilderView!
	@IBOutlet var demo2View: DSFAppKitBuilderView!
	@IBOutlet var demo3View: DSFAppKitBuilderView!
	@IBOutlet var demo4View: DSFAppKitBuilderView!
	@IBOutlet var demo5View: DSFAppKitBuilderView!

	let primaryLayout = PrimaryDSL()
	let secondaryLayout = SecondaryDSL()
	let scrollTest = ScrollerTestDSL()
	let tabTest = TabDSL()
	let splitTest = SplitDSL()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.demo1View.builder = self.primaryLayout
		self.demo2View.builder = self.secondaryLayout
		self.demo3View.builder = self.scrollTest
		self.demo4View.builder = self.tabTest
		self.demo5View.builder = self.splitTest
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
			Tab("first") {
				tab1
			}
			Tab("second") {
				VStack { Label("second") }
			}
			Tab("Third") {
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
