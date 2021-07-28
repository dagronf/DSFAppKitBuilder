//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder

class SecondaryDSL: NSObject, DSFAppKitBuilderViewHandler {
	
	lazy var body: Element =
		VStack(alignment: .leading) {
			HStack(spacing: 8) {
				ImageView(NSImage(named: "filter-icon")!)
					.scaling(.scaleProportionallyUpOrDown)
					.size(width: 36, height: 36)
				VStack(spacing: 0, alignment: .leading) {
					Label("Mount Everest")
						.font(NSFont.systemFont(ofSize: 18))
						.lineBreakMode(.byTruncatingTail)
						.horizontalPriorities(hugging: 100, compressionResistance: 100)
					Label("Mount Everest is really really tall")
						.lineBreakMode(.byTruncatingTail)
						.horizontalPriorities(hugging: 100, compressionResistance: 100)
				}
				.horizontalPriorities(hugging: .defaultLow)
			}
			CheckBox("Checkbox!")
				.action { button in
					Swift.print("State is now \(button.state)")
				}
		}
}