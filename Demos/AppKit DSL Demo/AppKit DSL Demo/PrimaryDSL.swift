//
//  PrimaryDSL.swift
//  PrimaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit
import DSFAppKitBuilder

class PrimaryDSL: NSObject, DSFAppKitBuilderViewHandler {
	func rootElement() -> Element {
		return self.layout
	}

	@objc dynamic var progressValue: Double = 33.0
	@objc dynamic var descriptionColor: NSColor = .textColor


	@objc dynamic var stepperStringValue: String = "0.0"
	@objc dynamic var stepperValue: Double = 0.0 {
		didSet {
			self.stepperStringValue = "\(self.stepperValue)"
		}
	}


	@objc dynamic var sliderStringValue: String = "0.0"
	@objc dynamic var sliderValue: Double = 50.0 {
		didSet {
			self.sliderStringValue = "\(self.sliderValue)"
		}
	}

	@objc dynamic var switchOn: Bool = false
	@objc dynamic var switchState: NSControl.StateValue = .off {
		didSet {
			self.switchOn = (self.switchState == .on)
		}
	}

	@objc dynamic var selectedSegments = NSSet(array: [0, 2])


	lazy var layout =
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
						.bindTextColor(self, keyPath: \PrimaryDSL.descriptionColor, animated: true)
						.lineBreakMode(.byTruncatingTail)
						.allowsDefaultTighteningForTruncation(true)
						.horizontalPriorities(hugging: .stackFiller, compressionResistance: .defaultLow)
					ProgressBar()
						.bindValue(self, keyPath: \PrimaryDSL.progressValue)
				}
				Divider(direction: .vertical)
				Button(title: "what?") { [weak self] _ in
					guard let `self` = self else { return }

					Swift.print("You pressed it!")
					self.progressValue = Double.random(in: 0 ... 100)
					self.descriptionColor = NSColor.randomRGB()
					self.selectedSegments = NSSet(array: [1])
				}
				.horizontalPriorities(hugging: .required)
			}

			Divider(direction: .horizontal)

			HStack {
				Label("Select something interesting")
					.lineBreakMode(.byTruncatingHead)
					.horizontalPriorities(hugging: .defaultLow)
				PopupButton {
					MenuItem(title: "Cats")
					MenuItem(title: "Dogs")
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
					.bindLabel(self, keyPath: \PrimaryDSL.stepperStringValue)
					.width(50)
				Stepper()
					.bindValue(self, keyPath: \PrimaryDSL.stepperValue)
			}

			HStack {
				Switch(state: .on)
					.bindState(self, keyPath: \PrimaryDSL.switchState)
				Slider(range: 0 ... 100, value: 10)
					.bindIsEnabled(self, keyPath: \PrimaryDSL.switchOn)
					.bindValue(self, keyPath: \PrimaryDSL.sliderValue)
				Label()
					.bindIsEnabled(self, keyPath: \PrimaryDSL.switchOn)
					.alignment(.right)
					.isBezeled(true)
					.isSelectable(true)
					.bindLabel(self, keyPath: \PrimaryDSL.sliderStringValue)
					.width(50)
			}

			HStack {
				VStack {
					Segmented(trackingMode: .selectAny) {
						Segment("One")
						Segment("Two")
						Segment("Three")
					}
					.bindSelectedSegments(self, keyPath: \PrimaryDSL.selectedSegments)
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
