//
//  PrimaryDSL.swift
//  PrimaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit
import DSFAppKitBuilder

class PrimaryDSL: NSObject, DSFAppKitBuilderHandler {
	func rootElement() -> Element {
		return self.layout
	}

	@objc dynamic var progressValue: Double = 0.0
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
						.contentHugging(h: .stackFiller)
						.contentCompressionResistance(h: .defaultLow)
						.minWidth(50)
					Label("• Mount Everest is really really tall •")
						.font(NSFont.systemFont(ofSize: 12))
						.bindTextColor(self, keyPath: \PrimaryDSL.descriptionColor, animated: true)
						.lineBreakMode(.byTruncatingTail)
						.allowsDefaultTighteningForTruncation(true)
						.contentHugging(h: .stackFiller)
						.contentCompressionResistance(h: .defaultLow)
					ProgressBar()
						.bindValue(self, keyPath: \PrimaryDSL.progressValue)
				}
				Divider(direction: .vertical)
				Button("what?") { [weak self] _ in
					guard let `self` = self else { return }

					Swift.print("You pressed it!")
					self.progressValue = Double.random(in: 0 ... 100)
					self.descriptionColor = NSColor.randomRGB()
				}
				.contentHugging(h: .required)
			}

			Divider(direction: .horizontal)

			HStack {
				Label("Select something interesting")
					.lineBreakMode(.byTruncatingHead)
					.contentCompressionResistance(h: .defaultLow)
				PopupButton {
					MenuItem(title: "Cats")
					MenuItem(title: "Dogs")
					MenuItem(title: "Caterpillar")
				}
				.onChange { popup in
					Swift.print("popup changed \(popup.selectedIndex)")
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
		}
}
