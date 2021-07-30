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

/// An individual radio element for the group
public class RadioElement {
	let title: String
	let toolTip: String?
	public init(
		_ title: String,
		toolTip: String? = nil
	) {
		self.title = title
		self.toolTip = toolTip
	}
}

/// A group of managed radio buttons
public class RadioGroup: Control {
	public convenience init(
		tag: Int? = nil,
		selected: Int = 0,
		controlSize: NSButton.ControlSize? = nil,
		spacing _: CGFloat? = nil,
		@RadioBuilder builder: () -> [RadioElement]
	) {
		self.init(
			tag: tag,
			selected: selected,
			controlSize: controlSize,
			content: builder()
		)
	}

	// Private

	override public var nsView: NSView { return self.radioGroup }
	private let radioGroup = NSStackView()
	private let content: [RadioElement]

	private var actionCallback: ((Int) -> Void)?
	private lazy var selectionBinder = Bindable<Int>()

	internal init(
		tag: Int? = nil,
		selected: Int = 0,
		controlSize: NSButton.ControlSize? = nil,
		spacing: CGFloat? = nil,
		content: [RadioElement]
	) {
		self.content = content
		super.init(tag: tag)

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

public extension RadioGroup {
	/// Set the initial selection for the RadioGroup
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
		if self.selectionBinder.isActive {
			self.selectionBinder.setValue(item.tag)
		}
	}
}

// MARK: - Bindings

public extension RadioGroup {
	/// Bind the selection to a keypath
	func bindSelection<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Int>) -> Self {
		self.selectionBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			guard let `self` = self else { return }
			self.selectRadioWithTag(newValue)
			self.actionCallback?(newValue)
		})
		self.selectionBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
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
