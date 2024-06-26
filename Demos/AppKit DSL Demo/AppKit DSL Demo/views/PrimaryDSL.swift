//
//  PrimaryDSL.swift
//  PrimaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit
import DSFAppearanceManager
import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders
import DSFStepperView

class PrimaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	let progressValue = ValueBinder<Double>(33.0)

	let descriptionColor = ValueBinder<NSColor>(.textColor)


	let stepperStringValue = ValueBinder<String>("0.0")
	lazy var stepperValue = ValueBinder<Double>(0.0) { newValue in
		self.stepperStringValue.wrappedValue = "\(newValue)"
	}

	let sliderStringValue = ValueBinder<String>("0.0")
	lazy var sliderValue = ValueBinder<Double>(50.0) { newValue in
		self.sliderStringValue.wrappedValue = self.numberFormatter.string(for: newValue) ?? "0.0"
	}

	let switchOn = ValueBinder<Bool>(false)
	let switchState = ValueBinder<NSControl.StateValue>(.off)

	let selectedSegments = ValueBinder(NSSet(array: [0, 2]))

	let numberFormatter: NumberFormatter = {
		let n = NumberFormatter()
		n.maximumFractionDigits = 1
		n.minimumFractionDigits = 1
		return n
	}()

	// A binding to tie buttons together into a radio-style grouping
	let selectedColor = ValueBinder(RadioBinding()) { newValue in
		Swift.print("Selected radio button = \(newValue.selectedIndex) (\(String(describing: newValue.selectedID))")
	}

	let comboboxContent = ValueBinder<[String]>(
		["red", "green", "blue", "yellow", "cyan", "magenta", "black"]
	)

	var comboboxText = ValueBinder<String>("") { newValue in
		Swift.print("Combo text is = \(newValue)")
	}

	var comboboxSelection = ValueBinder<Int>(-1) { newValue in
		Swift.print("Combo selection is = \(newValue)")
	}

	// StepperView
	let stepperViewValue = ValueBinder<Double?>(1)
	let stepperViewFormatter: NumberFormatter = {
		let n = NumberFormatter()
		n.numberStyle = .ordinal
		return n
	}()
	let stepperEnabled = ValueBinder(false)
	weak var stepperControl: DSFStepperView?

	// Definition

	lazy var body: Element =
	Group(edgeInset: 16) {
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
			
			VStack {
				HStack {
					Label("Select something interesting")
						.lineBreakMode(.byTruncatingHead)
						.horizontalPriorities(hugging: .defaultLow)
					PopupButton {
						MenuItem("Cats")
						MenuItem("Dogs")
						Separator()
						MenuItem("Caterpillar")
					}
					.onChange { popupIndex in
						Swift.print("popup changed - now \(popupIndex)")
					}
					.selectItem(at: 1)
					
				}
				
				HStack {
					Label("And in a combo box ->")
					
					ComboBox(content: comboboxContent, completes: true, initialSelection: 1)
						.bindText(comboboxText)
						.bindSelection(comboboxSelection)
						.width(100)
						.onEndEditing { newValue in
							Swift.print("ComboBox onEndEditing with value '\(newValue)'")
						}
						.onSelectionChange { newSelection in
							Swift.print("ComboBox onSelectionChange with value '\(newSelection)'")
						}
					
					Button(title: "Randomize Order") { [unowned self] _ in
						self.comboboxContent.wrappedValue = self.comboboxContent.wrappedValue.shuffled()
					}
				}
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
				CompatibleSwitch(onOffBinder: self.switchOn)
				Slider(range: 0 ... 100, value: 10)
					.bindIsEnabled(self.switchOn)
					.bindValue(self.sliderValue)
				Label()
					.bindIsEnabled(self.switchOn)
					.formatter(self.numberFormatter)
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
			
			HDivider()
			
			Label("Color Well")
				.font(NSFont.systemFont(ofSize: 16, weight: .medium))
			
			HStack {
				ColorWell(showsAlpha: true)
					.size(width: 60, height: 40)
					.onChange { color in
						Swift.print("Color - \(color)")
					}
			}
			
			HDivider()
			
			Label("Grouping buttons with a radio group")
				.font(NSFont.systemFont(ofSize: 16, weight: .medium))
			
			HStack {
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .white }
					.onChange { state in
						Swift.print("Color multicolor!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemBlue }
					.onChange { state in
						Swift.print("Color blue!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor, initialSelection: true)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemPurple }
					.onChange { state in
						Swift.print("Color purple!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemPink }
					.onChange { state in
						Swift.print("Color pink!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemRed }
					.onChange { state in
						Swift.print("Color red!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemOrange }
					.onChange { state in
						Swift.print("Color orange!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemYellow }
					.onChange { state in
						Swift.print("Color yellow!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemGreen }
					.onChange { state in
						Swift.print("Color green!")
					}
				Button(title: "", type: .momentaryChange, customButton: AccentColorButton())
					.bindRadioGroup(self.selectedColor)
					.additionalAppKitControlSettings { (item: AccentColorButton) in item.fillColor = .systemGray }
					.onChange { state in
						Swift.print("Color graphite!")
					}
				Button(title: "pink!") { _ in
					self.selectedColor.wrappedValue.activate(at: 3)
				}
			}
			
			HDivider()

			HStack {
				VStack {
					Label("Default")
					StepperView(style: .init(indicatorColor: NSColor.systemBlue))
						.bindValue(self.stepperViewValue)
						.onChange { newValue in
							Swift.print("StepperView: newValue is \(newValue?.description ?? "nil")")
						}
						.size(width: 120, height: 32)
				}

				VStack {
					Label("Disabled")
					StepperView(style: .init(numberFormatter: stepperViewFormatter))
						.bindValue(self.stepperViewValue)
						.bindIsEnabled(.init(false))
						.onChange { newValue in
							Swift.print("StepperView: newValue is \(newValue?.description ?? "nil")")
						}
						.size(width: 120, height: 32)
				}

				VStack {
					Label("Editable")
					StepperView(nil, allowsEmptyValue: true, allowsKeyboardInput: true)
						.onChange { newValue in
							Swift.print("StepperView: newValue is \(newValue?.description ?? "nil")")
						}
						.plaeholderText("inherited")
						.size(width: 120, height: 32)
				}
			}

			HStack {
				CompatibleSwitch(onOffBinder: self.stepperEnabled)
				StepperView(35, style: .init(textColor: .systemRed, borderColor: .systemRed, backgroundColor: .systemRed.withAlphaComponent(0.2), indicatorColor: .systemRed))
					.bindIsEnabled(stepperEnabled)
					.size(width: 100, height: 28)
				StepperView(35, style: .init(textColor: .systemGreen, borderColor: .systemGreen, backgroundColor: .systemGreen.withAlphaComponent(0.2), indicatorColor: .systemGreen))
					.bindIsEnabled(stepperEnabled)
					.size(width: 100, height: 28)
				StepperView(35, style: .init(textColor: .systemBlue, borderColor: .systemBlue, backgroundColor: .systemBlue.withAlphaComponent(0.2), indicatorColor: .systemBlue))
					.bindIsEnabled(stepperEnabled)
					.size(width: 100, height: 28)
					.bindControl(to: &stepperControl)
			}

			EmptyView()
				.onChange(of: self.stepperViewValue) { newValue in
					Swift.print("On change: \(newValue)")
				}
		}
	}
}
