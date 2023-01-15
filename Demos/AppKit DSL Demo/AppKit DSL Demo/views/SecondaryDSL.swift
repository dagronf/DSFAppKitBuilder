//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder
import DSFValueBinders

class SecondaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	let radioSelection = ValueBinder<Int>(1)
	let firstName = ValueBinder<String>("")

	let dateSelection1 = ValueBinder(Date()) { newValue in
		Swift.print("dateSelection1 is now \(newValue)")
	}
	let dateSelection2 = ValueBinder(Date().addingTimeInterval(-3600)) { newValue in
		Swift.print("dateSelection2 is now \(newValue)")
	}
	let dateTimeRangeSelection = ValueBinder(DatePicker.Range()) { newValue in
		Swift.print("dateTimeRangeSelection is now \(newValue)")
	}
	let dateSelectionMinMax = ValueBinder(Date()) { newValue in
		Swift.print("dateSelectionMinMax is now \(newValue)")
	}

	override init() {
		super.init()

		firstName.register { newValue in
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

	let numberValueBinder = ValueBinder(125.0)

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

		HDivider()

		Group(layoutType: .center) {
			VStack {
				HStack {
					DatePicker(date: dateSelection1)
					Button(title: "Now") { [weak self] _ in
						self?.dateSelection1.wrappedValue = Date()
					}
				}
				HStack {
					DatePicker(date: dateSelection2)
						.locale(Locale(identifier: "GMT"))
					Button(title: "Now") { [weak self] _ in
						self?.dateSelection2.wrappedValue = Date()
					}
				}
				HStack {
					DatePicker(
						range: dateTimeRangeSelection,
						style: .clockAndCalendar
					)
					Button(title: "Now") { [weak self] _ in
						self?.dateTimeRangeSelection.wrappedValue = DatePicker.Range()
					}
				}
				Label("Only allow selecting dates from the current time onwards")
				HStack {
					DatePicker(date: dateSelectionMinMax)
						.range(min: Date())
					Button(title: "Now") { [weak self] _ in
						self?.dateSelectionMinMax.wrappedValue = Date()
					}
				}
			}
		}

		HDivider()

		Group(layoutType: .center) {
			HStack {
				HStack {
					Label()
						.alignment(.right)
						.isBezeled(true)
						.isSelectable(true)
						.bindLabel(self.numberValueBinder.intValue().stringValue())
						.width(50)
					Stepper(range: -10000...10000)
						.bindValue(self.numberValueBinder)
					VDivider()
					Label("")
						.bindLabel(self.numberValueBinder.intValue().asWords())
				}
			}
			.width(400)
		}

		EmptyView()
			.verticalPriorities(hugging: 10, compressionResistance: 10)
	}
	.horizontalPriorities(hugging: .defaultLow)
}
