//
//  SplitDSL.swift
//  SplitDSL
//
//  Created by Darren Ford on 29/7/21.
//

import AppKit
import DSFAppKitBuilder

class SplitDSL: NSObject, DSFAppKitBuilderViewHandler {
	@objc dynamic var hidden = NSSet()

	lazy var body: Element =
//		Box("Split Testing") {
//			VStack {
//				HStack(alignment: .centerY) {
//					Label("Click a segment to turn off the split item")
//					Segmented(trackingMode: .selectAny) {
//						Segment("first")
//						Segment("second")
//						Segment("third")
//					}
//					.bindSelectedSegments(self, keyPath: \SplitDSL.hidden)
//				}

				SplitView {
					SplitViewItem(content: split1)
					SplitViewItem(content: split2)
					SplitViewItem(content: split3)
				}
				.bindHiddenViews(self, keyPath: \SplitDSL.hidden)
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
		}
		.backgroundColor(.systemGreen)
	lazy var split3: Element =
		VStack {
			Label("third")
		}
		.backgroundColor(.systemBlue)
}
