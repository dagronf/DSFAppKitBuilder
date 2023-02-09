//
//  RadioGroup.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit
import DSFValueBinders

/// A group of managed radio buttons
///
/// Usage:
///
/// ```swift
/// RadioGroup() {
///    RadioElement("first")
///    RadioElement("second")
///    RadioElement("third")
/// }
/// .bindSelection(self.radioSelection)
/// .onChange { whichSelection in
///    Swift.print("radio is now \(whichSelection)")
/// }
/// ```
public class RadioGroup: Control {
	/// Create a vertical radio group
	/// - Parameters:
	///   - orientation: The orientation for the radio buttons (vertically/horizontally)
	///   - selected: Which of the group should be initially selected
	///   - controlSize: The size for the control
	///   - spacing: The spacing between radio buttons in the control
	///   - builder: The builder for generating the group of radio elements
	public convenience init(
		orientation: NSUserInterfaceLayoutOrientation = .vertical,
		selected: Int = 0,
		controlSize: NSButton.ControlSize? = nil,
		spacing: CGFloat? = nil,
		@RadioBuilder builder: () -> [RadioElement]
	) {
		self.init(
			orientation: orientation,
			selected: selected,
			controlSize: controlSize,
			spacing: spacing,
			content: builder()
		)
	}

	deinit {
		self.selectionBinder?.deregister(self)
	}

	// Private

	override public func view() -> NSView { return self.radioGroup }
	private let radioGroup = NSStackView()
	private let content: [RadioElement]

	private var actionCallback: ((Int) -> Void)?
	private var selectionBinder: ValueBinder<Int>?

	private var isEnabledBinder: ValueBinder<Bool>?
	private var radioElementDisabledBinder: ValueBinder<NSSet>?

	internal init(
		orientation: NSUserInterfaceLayoutOrientation = .vertical,
		selected: Int = 0,
		controlSize: NSButton.ControlSize? = nil,
		spacing: CGFloat? = nil,
		content: [RadioElement]
	) {
		self.content = content
		super.init()

		self.radioGroup.orientation = orientation
		self.radioGroup.alignment = (orientation == .vertical) ? .leading : .firstBaseline
		if let s = spacing {
			self.radioGroup.spacing = s
		}
		self.radioGroup.edgeInsets = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)

		content.enumerated().forEach { item in
			let button = NSButton()
			button.setButtonType(.radio)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.tag = item.0
			button.title = item.1.title
			button.toolTip = item.1.toolTip
			button.state = (selected == item.0) ? .on : .off

			if let s = controlSize { button.controlSize = s }

			button.target = self
			button.action = #selector(radioSelected(_:))

			button.setContentHuggingPriority(.defaultLow, for: .horizontal)
			button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
			button.setContentHuggingPriority(.defaultHigh, for: .vertical)
			button.setContentCompressionResistancePriority(.required, for: .vertical)

			radioGroup.addArrangedSubview(button)
		}
	}

	/// Bind the radio group isEnabled state to a valuebinder
	override public func bindIsEnabled(_ enabledBinding: ValueBinder<Bool>) -> Self {
		self.isEnabledBinder = enabledBinding
		enabledBinding.register { [weak self] newValue in
			self?.updateElementEnabledStates()
		}
		return self
	}
}

// MARK: - Modifiers

internal extension RadioGroup {
	// Set the currently selected radio button
	func selectRadioWithTag(_ tag: Int) {
		let rds = self.radioGroup.arrangedSubviews as? [NSButton]
		rds?.forEach { $0.state = ($0.tag == tag) ? .on : .off }
	}
}

// MARK: - Actions

public extension RadioGroup {
	/// Set a callback block for when the selection changes
	func onChange(_ block: @escaping (Int) -> Void) -> Self {
		self.actionCallback = block
		return self
	}

	@objc private func radioSelected(_ item: NSButton) {
		self.actionCallback?(item.tag)

		// Tell the binder to update
		self.selectionBinder?.wrappedValue = item.tag
	}
}

// MARK: - Bindings

public extension RadioGroup {
	/// Bind the selection
	func bindSelection(_ selectionBinder: ValueBinder<Int>) -> Self {
		self.selectionBinder = selectionBinder
		selectionBinder.register { [weak self] newValue in
			guard let `self` = self else { return }
			self.selectRadioWithTag(newValue)
			self.actionCallback?(newValue)
		}
		return self
	}

	/// Bind individual radio items to a set to indicate which element(s) are disabled
	func bindRadioElementsDisabled(_ binder: ValueBinder<NSSet>) -> Self {
		self.radioElementDisabledBinder = binder
		binder.register { [weak self] _ in
			self?.updateElementEnabledStates()
		}
		return self
	}

	private func updateElementEnabledStates() {
		if let enabledBinding = self.isEnabledBinder {
			let state = enabledBinding.wrappedValue
			self.radioGroup.arrangedSubviews.compactMap { $0 as? NSButton }
				.forEach { $0.isEnabled = state }
		}

		if	self.isEnabledBinder?.wrappedValue ?? true == true,
			let individuals = radioElementDisabledBinder {
			let state = individuals.wrappedValue

			self.radioGroup.arrangedSubviews
				.enumerated()
				.compactMap {
					if let b = $0.1 as? NSButton {
						return (index: $0.0, button: b)
					}
					return nil
				}
				.forEach { (item: (index: Int, button: NSButton)) in
					let isDisabled = state.contains(item.index)
					item.button.isEnabled = !isDisabled
				}
		}
	}
}

// MARK: - RadioElement

/// An individual radio element for the group
public class RadioElement {
	let title: String
	let toolTip: String?

	/// Create a radio button within a radio group
	/// - Parameters:
	///   - title: The title to use for the radio control
	///   - toolTip: The tooltip
	public init(
		_ title: String,
		toolTip: String? = nil
	) {
		self.title = title
		self.toolTip = toolTip
	}
}

// MARK: - Result builder for RadioElements

@resultBuilder
public enum RadioBuilder {
	static func buildBlock() -> [RadioElement] { [] }
}

/// A resultBuilder to build menus
public extension RadioBuilder {
	static func buildBlock(_ settings: RadioElement...) -> [RadioElement] {
		settings
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

private let __enabler = ValueBinder(true)
private let __elementDisabler = ValueBinder(NSSet(array: [1]))
private let __enabler2 = ValueBinder(true)

@available(macOS 10.15, *)
struct RadioPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
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
					Switch(onOffBinder: __enabler)
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
					Switch(onOffBinder: __enabler2)
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
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
