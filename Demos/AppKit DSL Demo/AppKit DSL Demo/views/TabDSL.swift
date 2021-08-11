//
//  TabDSL.swift
//  TabDSL
//
//  Created by Darren Ford on 29/7/21.
//

import AppKit
import DSFAppKitBuilder

class TabDSL: NSObject, DSFAppKitBuilderViewHandler {
	let selectedTab = ValueBinder<Int>(1) { newValue in
		Swift.print("Changed tabs - now \(newValue)")
	}

	lazy var body: Element =
		TabView(tabViewType: .bottomTabsBezelBorder, selectedIndex: 2) {
			TabViewItem("first") {
				inner
			}
			TabViewItem("second") {
				VStack { Label("second") }
			}
			TabViewItem("Image") {
				ImageView(NSImage(named: "filter-icon"))
					.scaling(.scaleProportionallyUpOrDown)
			}
		}
		.bindTabIndex(self.selectedTab)

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
