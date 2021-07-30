//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder

class SecondaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	@objc dynamic var radioSelection: Int = 1
	@objc dynamic var firstName: String = "" {
		didSet {
			Swift.print("First name changed to '\(firstName)'")
		}
	}

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
			.onAction { state in
				Swift.print("State is now \(state)")
			}

		RadioGroup() {
			RadioElement("first")
			RadioElement("second")
			RadioElement("third")
		}
		.bindSelection(self, keyPath: \SecondaryDSL.radioSelection)
		.onChange { which in
			Swift.print("radio is now \(which)")
		}

		Button(title: "Reset radio")
			.onAction { [weak self] _ in
				self?.radioSelection = 0
			}

		Divider(direction: .horizontal)

		HStack {
			TextField()
				.placeholderText("First Name")
				.bindText(updateOnEndEditingOnly: true, self, keyPath: \SecondaryDSL.firstName)
			Button(title: "Reset") { [weak self] _ in
				self?.firstName = ""
			}
		}

		Box("Fishy") {
			VStack {
				Label("This is test")
					.horizontalPriorities(hugging: 10)
				TextField()
					.placeholderText("Noodles")
					.horizontalPriorities(hugging: 10)
				EmptyView()
					.verticalPriorities(hugging: 10, compressionResistance: 10)
					.horizontalPriorities(hugging: 10, compressionResistance: 10)
			}
			.edgeInsets(8)
			.hugging(h: 10)
		}
		.verticalPriorities(hugging: 100)
		.horizontalPriorities(hugging: 100)

		//EmptyView()
	}
	.horizontalPriorities(hugging: .defaultLow)
}
