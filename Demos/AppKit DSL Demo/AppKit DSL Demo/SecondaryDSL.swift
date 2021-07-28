//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder

class SecondaryDSL: NSObject, DSFAppKitBuilderViewHandler {
	func rootElement() -> Element {
		return self.layout
	}

	lazy var layout =
		VStack {
			HStack(spacing: 8) {
				ImageView(NSImage(named: "filter-icon")!)
					.scaling(.scaleProportionallyUpOrDown)
					.size(width: 36, height: 36)
				VStack(spacing: 0, alignment: .leading) {
					Label("Mount Everest")
						.font(NSFont.systemFont(ofSize: 18))
						.contentHugging(h: .stackFiller)
					Label("Mount Everest is really really tall")
						.contentHugging(h: .stackFiller)
				}
				.contentHugging(h: .defaultLow)
			}
			.contentHugging(h: .defaultLow)
			CheckBox("Checkbox!")
		}
}

