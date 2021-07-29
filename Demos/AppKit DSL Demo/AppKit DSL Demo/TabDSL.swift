//
//  TabDSL.swift
//  TabDSL
//
//  Created by Darren Ford on 29/7/21.
//

import AppKit
import DSFAppKitBuilder

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
