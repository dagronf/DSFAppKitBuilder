//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class SecondaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	let radioSelection = ValueBinder(1)

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

	private lazy var menu1: NSMenu = NSMenu {
		MenuItem("first")
			.enabled { [weak self] in true }
			.onAction { [weak self] in Swift.print("Menu selected - first") }
		MenuItem("second")
			.enabled { [weak self] in true }
			.onAction { [weak self] in Swift.print("Menu selected - second") }
		MenuItem("third")
			.enabled { [weak self] in true }
			.onAction { [weak self] in Swift.print("Menu selected - third") }
	}

	private var menu2Count = 0

	private var rabbitComboTitle = ValueBinder("Rabbit")
	private lazy var rabbitMenu: NSMenu = NSMenu {
		MenuItem("first")
			.enabled { [weak self] in true }
			.onAction { [weak self] in self?.rabbitComboTitle.wrappedValue = "first" }
		MenuItem("second")
			.enabled { [weak self] in true }
			.onAction { [weak self] in self?.rabbitComboTitle.wrappedValue = "second" }
		MenuItem("third")
			.enabled { [weak self] in true }
			.onAction { [weak self] in self?.rabbitComboTitle.wrappedValue = "third" }
	}
	// Body

	lazy var body: Element =
	Group(edgeInset: 16) {
		VStack(alignment: .leading, distribution: .fillProportionally) {

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
			.width(400)

			HDivider()

			Label("Combo Buttons")

			HStack {
				ComboButton(
					style: .split,
					"Split (fixed menu)",
					image: NSImage(named: "status-bar-icon"),
					menu: menu1
				) {
					Swift.print("Split Button pressed!")
				}
				.horizontalPriorities(hugging: 999)

				ComboButton(style: .unified, "Unified (dynamic menu)", menu: nil) {
					Swift.print("Unified Button pressed!")
				}
				.horizontalPriorities(hugging: 999)
				.generateMenu { [weak self] in
					guard let `self` = self else { return nil }
					let count = self.menu2Count
					self.menu2Count += 1
					return NSMenu {
						MenuItem("first \(count)")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Unified menu selected - first \(count)") }
						MenuItem("second \(count)")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Unified menu selected - second \(count)") }
						MenuItem("third \(count)")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Unified menu selected - third \(count)") }
					}
				}

				ComboButton(
					style: .split,
					"Rabbit",
					image: NSImage(named: "slider-rabbit"),
					menu: nil
				) {
					Swift.print("Unified Button pressed!")
				}
				.horizontalPriorities(hugging: 999)
				.generateMenu { [weak self] in
					NSMenu {
						MenuItem("Do Rabbit")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Rabbit be did!") }
					}
				}

				ComboButton(
					style: .split,
					"Rabbit",
					image: NSImage(named: "slider-rabbit"),
					menu: rabbitMenu
				) { [weak self] in
					if let w = self?.rabbitComboTitle.wrappedValue {
						Swift.print("Unified Button pressed (\(w))!")
					}
				}
				.bindTitle(rabbitComboTitle)
				.controlSize(.small)
				.horizontalPriorities(hugging: 999)
			}

			HDivider()
			EmptyView()
		}
	}
	.horizontalPriorities(hugging: .defaultLow)
}
