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
				inner
			}
			TabViewItem("second") {
				VStack { Label("second") }
			}
			TabViewItem("Third") {
				VStack { Label("third") }
			}
		}
		.bindTabIndex(self, keyPath: \TabDSL.selectedTab)


	lazy var inner: Element =
		TabView(tabViewType: .rightTabsBezelBorder, selectedIndex: 0) {
			TabViewItem("first") {
				VStack { Label("first-first") }
			}
			TabViewItem("second") {
				VStack { Label("first-second") }
			}
			TabViewItem("Third") {
				VStack { Label("first-third") }
			}
		}
}
