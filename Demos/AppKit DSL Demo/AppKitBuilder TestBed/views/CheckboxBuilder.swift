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
			Label("Checkbox").font(.headline)
			VStack(alignment: .leading) {
				self.checkboxBody
					.padding(4)
			}
			.edgeInsets(4)
			.cornerRadius(4)
			.border(width: 0.5, color: NSColor.tertiaryLabelColor)
			.backgroundColor(NSColor.tertiaryLabelColor.withAlphaComponent(0.05))
			.hugging(h: 10)

			Box("RadioGroup") {
				self.radioBody
					.padding(4)
			}
			.titleFont(.headline)
			.horizontalHuggingPriority(10)
		}
		.hugging(h: 10)
	}()

	lazy var checkboxBody: Element = {
		VStack(alignment: .leading) {
			CheckBox("off", allowMixedState: true)
				.state(.off)
				.horizontalHuggingPriority(10)
			CheckBox("on", allowMixedState: true)
				.state(.on)
				.horizontalHuggingPriority(10)
			CheckBox("mixed", allowMixedState: true)
				.state(.mixed)
				.horizontalHuggingPriority(10)
			CheckBox("disabled")
				.state(.on)
				.isEnabled(false)
				.horizontalHuggingPriority(10)

			HDivider()

			HStack {
				Label(String("Hiding the checkbox title:").localized())
				CheckBox("This is a checkbox")
					.hidesTitle(true)
					.border(width: 1, color: .red)
			}

			HDivider()

			HStack {
				CheckBox("This is the first checkbox", allowMixedState: true)
					.bindState(__state1)
				EmptyView()
				Button(title: "Toggle", bezelStyle: .roundRect) { [weak self] _ in
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

	lazy var radioBody: Element = {
		VStack(alignment: .leading) {
			Label("Vertical alignment (default settings)").font(.title3.bold())
			RadioGroup(orientation: .vertical) {
				RadioElement("first")
				RadioElement("second")
				RadioElement("third")
			}
			HDivider()
			Label("Horizontal alignment").font(.title3.bold())
			HStack {
				CompatibleSwitch(onOffBinder: __enabler)
				RadioGroup(orientation: .horizontal) {
					RadioElement("first 1")
					RadioElement("second 2")
					RadioElement("third 3")
				}
				.bindIsEnabled(__enabler)
			}
			HDivider()
			Label("Disable individual items").font(.title3.bold())
			HStack {
				CompatibleSwitch(onOffBinder: __enabler2)
				Label("Disabled radio elements ->")
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
				RadioElement("first")
				RadioElement("second")
				RadioElement("third")
			}
			.bindIsEnabled(__enabler2)
			.bindRadioElementsDisabled(__elementDisabler)
			EmptyView()
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
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
