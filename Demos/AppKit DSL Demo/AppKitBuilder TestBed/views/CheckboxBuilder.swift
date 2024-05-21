//
//  CheckboxBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 4/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders

public class CheckboxBuilder: ViewTestBed {
	var title: String { String.localized("Checkbox and Radio") }
	var type: String { "Checkbox/RadioGroup" }
	var description: String { String.localized("Elements for displaying checkboxes and groups of radio buttons") }
	func build() -> ElementController {
		CheckboxBuilderController()
	}
}

class CheckboxBuilderController: ElementController {

	private let __state1 = ValueBinder<NSControl.StateValue>(.on)

	lazy var body: Element = {
		VStack(spacing: 16, alignment: .leading) {
			FakeBox(NSLocalizedString("Checkboxes", comment: "Checkboxes are fun!"), font: .headline) {
				self.checkboxBody
					.padding(4)
			}
			Box(NSLocalizedString("RadioGroup", comment: ""), font: .headline) {
				self.radioBody
					.padding(4)
			}
			//.showDebugFrames()
		}
		.hugging(h: 10)
	}()

	lazy var checkboxBody: Element = {
		VStack(alignment: .leading) {
			CheckBox(NSLocalizedString("off", comment: ""), allowMixedState: true)
				.state(.off)
				.horizontalHuggingPriority(10)
			CheckBox(NSLocalizedString("on", comment: ""), allowMixedState: true)
				.state(.on)
				.horizontalHuggingPriority(10)
			CheckBox(NSLocalizedString("mixed", comment: ""), allowMixedState: true)
				.state(.mixed)
				.horizontalHuggingPriority(10)
			CheckBox(NSLocalizedString("disabled", comment: ""))
				.state(.on)
				.isEnabled(false)
				.horizontalHuggingPriority(10)

			HDivider()

			HStack {
				Label(NSLocalizedString("Hiding the checkbox title:", comment: ""))
				CheckBox(NSLocalizedString("This is a checkbox", comment: ""))
					.hidesTitle(true)
					.border(width: 1, color: .red)
			}

			HDivider()

			HStack {
				CheckBox(NSLocalizedString("This is the first checkbox", comment: ""), allowMixedState: true)
					.bindState(__state1)
				EmptyView()
				Button(title: NSLocalizedString("Toggle", comment: ""), bezelStyle: .roundRect) { [weak self] _ in
					guard let `self` = self else { return }
					let current = self.__state1.wrappedValue
					switch current {
					case .off: self.__state1.wrappedValue = .mixed
					case .mixed: self.__state1.wrappedValue = .on
					default: self.__state1.wrappedValue = .off
					}
				}
			}
			.hugging(h: 10)
		}
		.hugging(h: 1)
	}()

	private let __enabler = ValueBinder(true)
	private let __elementDisabler = ValueBinder(NSSet(array: [1]))
	private let __enabler2 = ValueBinder(true)

	let primarySelection = ValueBinder(1)

	lazy var radioBody: Element = {
		VStack(alignment: .leading) {
			Label("Vertical alignment (default settings)").font(.title3.bold())
			RadioGroup(orientation: .vertical) {
				RadioElement(NSLocalizedString("first", comment: ""))
				RadioElement(NSLocalizedString("second", comment: ""))
				RadioElement(NSLocalizedString("third", comment: ""))
			}
			.bindSelection(primarySelection)
			HStack(spacing: 4) {
				Label(NSLocalizedString("Selected radio button is", comment: ""))
				Label(primarySelection.stringValue())
			}

			HDivider()
			Label(NSLocalizedString("Horizontal alignment", comment: "")).font(.title3.bold())
			HStack {
				CompatibleSwitch(onOffBinder: __enabler)
				RadioGroup(orientation: .horizontal) {
					RadioElement(NSLocalizedString("first 1", comment: ""))
					RadioElement(NSLocalizedString("second 2", comment: ""))
					RadioElement(NSLocalizedString("third 3", comment: ""))
				}
				.bindIsEnabled(__enabler)
			}
			HDivider()
			Label(NSLocalizedString("Disable individual items", comment: "")).font(.title3.bold())
			HStack {
				CompatibleSwitch(onOffBinder: __enabler2)
				Label(NSLocalizedString("Disabled radio elements ->", comment: ""))
				Segmented(trackingMode: .selectAny) {
					Segment("1")
					Segment("2")
					Segment("3")
				}
				.bindIsEnabled(__enabler2)
				.width(100)
				.bindSelectedSegments(__elementDisabler)
			}
			RadioGroup(orientation: .vertical) {
				RadioElement(NSLocalizedString("first", comment: ""))
				RadioElement(NSLocalizedString("second", comment: ""))
				RadioElement(NSLocalizedString("third", comment: ""))
			}
			.bindIsEnabled(__enabler2)
			.bindRadioElementsDisabled(__elementDisabler)
			//EmptyView()
		}
		.hugging(h: 10)
	}()

}


#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct CheckboxBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				CheckboxBuilder().build().body
				DSFAppKitBuilder.EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
