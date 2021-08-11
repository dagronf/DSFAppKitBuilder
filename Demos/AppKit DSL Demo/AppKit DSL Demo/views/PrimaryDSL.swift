//
//  PrimaryDSL.swift
//  PrimaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit
import DSFAppKitBuilder

class PrimaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	let progressValue = ValueBinder<Double>(33.0)

	let descriptionColor = ValueBinder<NSColor>(.textColor)


	let stepperStringValue = ValueBinder<String>("0.0")
	lazy var stepperValue = ValueBinder<Double>(0.0) { newValue in
		self.stepperStringValue.wrappedValue = "\(newValue)"
	}

	let sliderStringValue = ValueBinder<String>("0.0")
	lazy var sliderValue = ValueBinder<Double>(50.0) { newValue in
		self.sliderStringValue.wrappedValue = "\(newValue)"
	}

	let switchOn = ValueBinder<Bool>(false)
	let switchState = ValueBinder<NSControl.StateValue>(.off)

	let selectedSegments = ValueBinder(NSSet(array: [0, 2]))

	// Definition

	lazy var body: Element =
		VStack {
			HStack(spacing: 8) {
				ImageView(NSImage(named: "filter-icon")!)
					.scaling(.scaleProportionallyUpOrDown)
					.size(width: 32, height: 32)
				VStack(spacing: 0, alignment: .leading) {
					Label("Mount Everest")
						.font(NSFont.systemFont(ofSize: 18))
						.lineBreakMode(.byTruncatingTail)
						.allowsDefaultTighteningForTruncation(true)
						.horizontalPriorities(hugging: .stackFiller, compressionResistance: .defaultLow)
						.minWidth(50)
					Label("• Mount Everest is really really tall •")
						.font(NSFont.systemFont(ofSize: 12))
						.bindTextColor(self.descriptionColor, animated: true)
						.lineBreakMode(.byTruncatingTail)
						.allowsDefaultTighteningForTruncation(true)
						.horizontalPriorities(hugging: .stackFiller, compressionResistance: .defaultLow)
					ProgressBar()
						.bindValue(self.progressValue)
				}
				VDivider()
				Button(title: "what?") { [weak self] _ in
					guard let `self` = self else { return }

					Swift.print("You pressed it!")
					self.progressValue.wrappedValue = Double.random(in: 0 ... 100)
					self.descriptionColor.wrappedValue = NSColor.randomRGB()
					self.selectedSegments.wrappedValue = NSSet(array: [1])
				}
				.horizontalPriorities(hugging: .required)
			}

			HDivider()

			HStack {
				Label("Select something interesting")
					.lineBreakMode(.byTruncatingHead)
					.horizontalPriorities(hugging: .defaultLow)
				PopupButton {
					MenuItem(title: "Cats")
					MenuItem(title: "Dogs")
					MenuItem.Divider()
					MenuItem(title: "Caterpillar")
				}
				.onChange { popupIndex in
					Swift.print("popup changed - now \(popupIndex)")
				}
				.selectItem(at: 1)
			}

			HStack {
				Label()
					.alignment(.right)
					.isBezeled(true)
					.isSelectable(true)
					.bindLabel(self.stepperStringValue)
					.width(50)
				Stepper()
					.bindValue(self.stepperValue)
			}

			HStack {
				Switch(state: .on)
					.bindState(self.switchState)
				Slider(range: 0 ... 100, value: 10)
					.bindIsEnabled(self.switchOn)
					.bindValue(self.sliderValue)
				Label()
					.bindIsEnabled(self.switchOn)
					.alignment(.right)
					.isBezeled(true)
					.isSelectable(true)
					.bindLabel(self.sliderStringValue)
					.width(50)
			}

			HStack {
				VStack {
					Segmented(trackingMode: .selectAny) {
						Segment("One")
						Segment("Two")
						Segment("Three")
					}
					.bindSelectedSegments(self.selectedSegments)
					.width(200)
					.toolTip("First segmented!")
					Label("Select Many")
						.font(NSFont.systemFont(ofSize: 9))
				}

				VStack {
					Segmented(trackingMode: .selectOne) {
						Segment("One", toolTip: "This is the first")
						Segment("Two", toolTip: "This is the second")
						Segment("Three", toolTip: "This is the last!")
					}
					.width(200)
					.onChange { selected in
						Swift.print(selected)
					}
					Label("Select One")
						.font(NSFont.systemFont(ofSize: 9))
				}
			}

			HStack {
				ColorWell(showsAlpha: true)
					.size(width: 60, height: 40)
					.onChange { color in
						Swift.print("Color - \(color)")
					}
			}
		}
}
