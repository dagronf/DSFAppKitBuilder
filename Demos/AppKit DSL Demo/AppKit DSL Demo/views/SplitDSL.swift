//
//  SplitDSL.swift
//  SplitDSL
//
//  Created by Darren Ford on 29/7/21.
//

import AppKit
import DSFAppKitBuilder

class SplitDSL: NSObject, DSFAppKitBuilderViewHandler {
	let hidden = ValueBinder(NSSet()) { newValue in
		Swift.print("Hidden Items = \(newValue)")
	}

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
					.bindSelectedSegments(self.hidden)
				}

				SplitView {
					SplitViewItem { self.split1 }
					SplitViewItem { self.split2 }
					SplitViewItem { self.split3 }
				}
				.bindHiddenViews(self.hidden)
				.verticalPriorities(hugging: 10, compressionResistance: 10)
				.horizontalPriorities(hugging: 10, compressionResistance: 10)
			}
			.verticalPriorities(hugging: 10, compressionResistance: 10)
			.horizontalPriorities(hugging: 10, compressionResistance: 10)
			.hugging(h: 10, v: 10)
		}
		.horizontalPriorities(hugging: 10, compressionResistance: 10)

	lazy var split1: Element =
		VStack {
			Label("first").horizontalPriorities(hugging: 1)
			Label("item2").horizontalPriorities(hugging: 1)
			EmptyView()
		}
		.hugging(h: 10)
		.backgroundColor(.systemRed)
	lazy var split2: Element =
		VStack {
			Label("second")
			EmptyView()
		}
		.hugging(h: 10)
		.backgroundColor(.systemGreen)
	lazy var split3: Element =
		VStack {
			Label("third")
			EmptyView()
		}
		.hugging(h: 10)
		.backgroundColor(.systemBlue)
}
