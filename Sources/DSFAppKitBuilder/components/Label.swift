//
//  Label.swift
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

import AppKit.NSTextField
import DSFValueBinders
import Foundation

/// A read-only text control
///
/// Usage:
///
/// ```swift
/// let textValue = ValueBinder("")
/// ...
/// Label()
///   .alignment(.right)
///   .lineBreakMode(.byTruncatingHead)
///   .horizontalPriorities(hugging: .defaultLow)
///   .bindLabel(self.textValue)
/// ```
public class Label: Control {
	
	/// Create a label control
	/// - Parameter label: The label
	public init(_ label: String? = nil) {
		super.init()
		self.configureDefaults()
		if let l = label { self.label.stringValue = l }
	}

	/// Create a label control
	/// - Parameter attributedLabel: An attributed string to use as the label
	public init(_ attributedLabel: NSAttributedString) {
		super.init()
		self.configureDefaults()
		self.label.attributedStringValue = attributedLabel
	}

	/// Create a label control
	/// - Parameter attributedLabel: An attributed string to use as the label
	public convenience init(_ attributedLabel: AKBAttributedString) {
		self.init(attributedLabel.attributedString)
	}

	/// Create a label using the new `AttributedString` type (macOS 12+)
	@available(macOS 12, *)
	public convenience init(_ attributedLabel: AttributedString) {
		self.init(NSAttributedString(attributedLabel))
	}

	/// Create a label control
	/// - Parameter stringBinder: A string binder containing the display value
	public init(_ stringBinder: ValueBinder<String>) {
		super.init()
		self.configureDefaults()
		_ = self.bindLabel(stringBinder)
	}

	/// Create a label control
	/// - Parameter stringBinder: An NSAttributedString binder containing the display value
	public init(_ attributedStringBinder: ValueBinder<NSAttributedString>) {
		super.init()
		self.configureDefaults()
		_ = self.bindAttributedLabel(attributedStringBinder)
	}

	deinit {
		self.labelBinder?.deregister(self)
		self.attributedLabelBinder?.deregister(self)
		self.doubleBinder?.deregister(self)
		self.textColorBinder?.deregister(self)

		if let c = self.clickDetector {
			self.label.removeGestureRecognizer(c)
			self.clickDetector = nil
		}
		self.onLabelClickBlock = nil
	}

	// Privates
	let label = PaddableTextField()
	override public func view() -> NSView { return self.label }

	private var labelBinder: ValueBinder<String>?
	private var attributedLabelBinder: ValueBinder<NSAttributedString>?

	private var doubleBinder: ValueBinder<Double>?

	private var textColorBinder: ValueBinder<NSColor>?
	private lazy var textColorAnimator = NSColor.Animator()

	// Click detection for non-editable Labels
	private var clickDetector: NSClickGestureRecognizer?
	private var onLabelClickBlock: (() -> Void)?
}

extension Label {
	// Set default settings for the field
	private func configureDefaults() {
		self.label.wantsLayer = true
		self.label.isEditable = false
		self.label.drawsBackground = false
		self.label.isBezeled = false

		// Required so that (by default) the field plays nicely in an RTL environment
		self.label.alignment = .natural
	}
}

// MARK: - Modifiers

public extension Label {
	/// The text to display in the label
	func label(_ label: String) -> Self {
		self.label.stringValue = label
		return self
	}

	/// The color of the text field’s content.
	func textColor(_ textColor: NSColor? = nil) -> Self {
		self.label.textColor = textColor
		return self
	}

	/// A Boolean value that determines whether the user can select the content of the text field.
	func isSelectable(_ s: Bool) -> Self {
		self.label.isSelectable = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a solid black border around its contents.
	func isBordered(_ s: Bool) -> Self {
		self.label.isBordered = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a bezeled background around its contents.
	func isBezeled(_ s: Bool) -> Self {
		self.label.isBezeled = s
		return self
	}

	/// Needs to be set IF the label contains an attributedstring with clickable link text.
	///
	/// See: https://developer.apple.com/library/archive/qa/qa1487
	func containsClickableLinks(_ hasClickableLinks: Bool) -> Self {
		// both are needed, otherwise hyperlink won't accept mousedown
		self.label.allowsEditingTextAttributes = hasClickableLinks
		self.label.isSelectable = hasClickableLinks
		return self
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	func drawsBackground(_ s: Bool) -> Self {
		self.label.drawsBackground = s
		return self
	}

	/// The alignment mode of the text in the receiver’s cell.
	func alignment(_ alignment: NSTextAlignment) -> Self {
		self.label.alignment = alignment
		return self
	}

	/// The line break mode to use when drawing text in the cell.
	func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
		self.label.cell?.lineBreakMode = mode
		return self
	}

	/// A Boolean value that controls whether single-line text fields tighten intercharacter spacing before truncating the text.
	func allowsDefaultTighteningForTruncation(_ allow: Bool) -> Self {
		self.label.allowsDefaultTighteningForTruncation = allow
		return self
	}

	/// Set a formatter for the field
	func formatter(_ formatter: Formatter) -> Self {
		self.label.formatter = formatter
		return self
	}

	/// Set whether the label wraps text whose length that exceeds the label's frame.
	func wraps(_ wraps: Bool) -> Self {
		self.label.cell?.wraps = wraps
		return self
	}

	/// Set whether the label truncates text that does not fit within the label's bounds.
	func truncatesLastVisibleLine(_ truncates: Bool) -> Self {
		self.label.cell?.truncatesLastVisibleLine = truncates
		return self
	}

	/// Set the maximum number of lines to display in a multiline text field
	func maximumNumberOfLines(_ lineCount: Int) -> Self {
		if lineCount > 0 {
			self.label.maximumNumberOfLines = lineCount
		}
		return self
	}

	/// Set a rounded bezel for the text field
	func roundedBezel() -> Self {
		if let cell = self.label.cell as? NSTextFieldCell {
			cell.bezelStyle = .roundedBezel
		}
		return self
	}
}

public extension Label {
	/// Apply padding to the text field
	final func labelPadding(_ value: CGFloat) -> Self {
		self.label.edgeInsets = NSEdgeInsets(edgeInset: value)
		return self
	}

	/// Apply padding to the text field
	final func labelPadding(_ value: NSEdgeInsets) -> Self {
		self.label.edgeInsets = value
		return self
	}
}

// MARK: - Actions

public extension Label {
	/// A block to be called when the label is clicked.
	///
	/// Asserts if the Label is editable (ie. its actually a TextField())
	func onLabelClicked(_ block: @escaping () -> Void) -> Self {
		guard self.label.isEditable == false else {
			assertionFailure("DSFAppKitBuilder.Label: onLabelClicked() cannot be applied to an editable text field, ignoring...")
			return self
		}

		let clickDetector = NSClickGestureRecognizer(target: self, action: #selector(self.clicked(_:)))
		self.clickDetector = clickDetector
		self.label.addGestureRecognizer(clickDetector)
		self.onLabelClickBlock = block
		return self
	}

	@objc func clicked(_ sender: Any) {
		self.onLabelClickBlock?()
	}
}

// MARK: - Bindings

public extension Label {
	/// Bind to the bindable string value
	/// - Parameters:
	///   - textValue: The value binding for the text to display
	/// - Returns: Self
	func bindLabel(_ textValue: ValueBinder<String>) -> Self {
		self.labelBinder = textValue
		textValue.register { [weak self] newValue in
			self?.label.stringValue = newValue
		}
		return self
	}

	/// Bind to the bindable double value using a formatter for display
	/// - Parameters:
	///   - doubleBinder: The value binding for the text to display
	///   - formatter: The formatter to use when displaying the value
	/// - Returns: Self
	func bindValue(_ doubleBinder: ValueBinder<Double>, formatter: NumberFormatter) -> Self {
		self.doubleBinder = doubleBinder
		self.label.formatter = formatter
		doubleBinder.register { [weak self] newValue in
			guard let `self` = self else { return }
			self.label.doubleValue = self.doubleBinder?.wrappedValue ?? 0
		}
		return self
	}

	/// Bind to the bindable attributestring value
	/// - Parameters:
	///   - textValue: The value binding for the text to display
	/// - Returns: Self
	func bindAttributedLabel(_ attributedValue: ValueBinder<NSAttributedString>) -> Self {
		self.attributedLabelBinder = attributedValue
		attributedValue.register { [weak self] newValue in
			self?.label.attributedStringValue = newValue
		}
		return self
	}

	/// Bind the text color
	func bindTextColor(_ colorBinder: ValueBinder<NSColor>, animated: Bool = false) -> Self {
		self.textColorBinder = colorBinder
		colorBinder.register { [weak self] newValue in
			guard let `self` = self else { return }
			if animated {
				self.textColorAnimator.animate(from: self.label.textColor ?? .clear, to: newValue) { [weak self] color in
					self?.label.textColor = color
				}
			}
			else {
				self.label.textColor = newValue
			}
		}
		return self
	}
}
