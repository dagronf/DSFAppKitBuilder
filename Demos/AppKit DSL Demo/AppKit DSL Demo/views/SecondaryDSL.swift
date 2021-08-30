//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder

class SecondaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	let radioSelection = ValueBinder<Int>(1)

	let firstName = ValueBinder<String>("")

	override init() {
		super.init()

		firstName.register(self) { newValue in
			Swift.print("First name changed to '\(newValue)'")
		}
	}

	let EverestBackgroundColor: NSColor = {
		if #available(macOS 10.13, *) {
			return NSColor(named: "secondary-background-color")!
		} else {
			return .clear
		}
	}()

	// Body

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
				Label("Mount Everest (Nepali: सगरमाथा, romanized: Sagarmāthā; Tibetan: Chomolungma ཇོ་མོ་གླང་མ) is Earth's highest mountain above sea level, located in the Mahalangur Himal sub-range of the Himalayas.")
					.lineBreakMode(.byTruncatingTail)
					.wraps(true)
					.horizontalPriorities(hugging: 100, compressionResistance: 100)
			}
			.horizontalPriorities(hugging: .defaultLow)
		}
		.border(width: 0.5, color: .textColor)
		.backgroundColor(EverestBackgroundColor)
		.cornerRadius(8)
		.edgeInsets(8)

		CheckBox("Checkbox!")
			.onChange { state in
				Swift.print("State is now \(state)")
			}

		RadioGroup() {
			RadioElement("first")
			RadioElement("second")
			RadioElement("third")
		}
		.bindSelection(self.radioSelection)
		.onChange { which in
			Swift.print("radio is now \(which)")
		}

		HStack {
			Button(title: "Reset radio")
				.onChange { [weak self] state in
					self?.radioSelection.wrappedValue = 0
				}
		}
		.verticalPriorities(hugging: 999, compressionResistance: 999)

		HDivider()

		HStack {
			TextField()
				.placeholderText("First Name")
				.bindText(firstName)
			Button(title: "Reset") { [weak self] state in
				guard let `self` = self else { return }
				self.firstName.wrappedValue = ""
			}
		}

		EmptyView()
	}
	.horizontalPriorities(hugging: .defaultLow)
}
