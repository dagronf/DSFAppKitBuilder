//
//  DSFAppKitBuilder+RadioGroup.swift
//
//  Created by Darren Ford on 27/7/21
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AppKit

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
/// .bindSelection(self, keyPath: \MyObject.radioSelection)
/// .onChange { whichSelection in
///    Swift.print("radio is now \(whichSelection)")
/// }
/// ```
public class RadioGroup: Control {


	/// Create a vertical radio group
	/// - Parameters:
	///   - selected: Which of the group should be initially selected
	///   - controlSize: The size for the control
	///   - spacing: The spacing between radio buttons in the control
	///   - builder: The builder for generating the group of radio elements
	public convenience init(
		selected: Int = 0,
		controlSize: NSButton.ControlSize? = nil,
		spacing: CGFloat? = nil,
		@RadioBuilder builder: () -> [RadioElement]
	) {
		self.init(
			selected: selected,
			controlSize: controlSize,
			spacing: spacing,
			content: builder()
		)
	}

	deinit {
		selectionBinder?.deregister(self)
	}

	// Private

	public override func view() -> NSView { return self.radioGroup }
	private let radioGroup = NSStackView()
	private let content: [RadioElement]

	private var actionCallback: ((Int) -> Void)?
	private var selectionBinder: ValueBinder<Int>?

	internal init(
		selected: Int = 0,
		controlSize: NSButton.ControlSize? = nil,
		spacing: CGFloat? = nil,
		content: [RadioElement]
	) {
		self.content = content
		super.init()

		self.radioGroup.orientation = .vertical
		self.radioGroup.alignment = .leading
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
	/// Bind the selection to a keypath
	func bindSelection(_ selectionBinder: ValueBinder<Int>) -> Self {
		self.selectionBinder = selectionBinder
		selectionBinder.register(self) { [weak self] newValue in
			guard let `self` = self else { return }
			self.selectRadioWithTag(newValue)
			self.actionCallback?(newValue)
		}
		return self
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

#if swift(<5.3)
@_functionBuilder
public enum RadioBuilder {
	static func buildBlock() -> [RadioElement] { [] }
}
#else
@resultBuilder
public enum RadioBuilder {
	static func buildBlock() -> [RadioElement] { [] }
}
#endif

/// A resultBuilder to build menus
public extension RadioBuilder {
	static func buildBlock(_ settings: RadioElement...) -> [RadioElement] {
		settings
	}
}
