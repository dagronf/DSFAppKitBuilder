//
//  DSFAppKitBuilder+Label.swift
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

import AppKit.NSTextField

/// A read-only text control
///
/// Usage:
///
/// ```swift
/// Label()
///   .alignment(.right)
///   .lineBreakMode(.byTruncatingHead)
///   .horizontalPriorities(hugging: .defaultLow)
///   .bindLabel(self, keyPath: \PrimaryDSL.stepperStringValue)
/// ```
public class Label: Control {
	/// Create a label control
	/// - Parameter label: The label
	public init(_ label: String? = nil) {
		super.init()
		self.label.isEditable = false
		self.label.drawsBackground = false
		self.label.isBezeled = false
		if let l = label { self.label.stringValue = l }
	}

	/// Create a label control
	/// - Parameter attributedLabel: An attributed string to use as the label
	public init(_ attributedLabel: NSAttributedString) {
		self.label.isEditable = false
		self.label.drawsBackground = false
		self.label.isBezeled = false
		self.label.attributedStringValue = attributedLabel
	}

	deinit {
		labelBinder?.deregister(self)
		attributedLabelBinder?.deregister(self)
		textColorBinder?.deregister(self)
	}

	// Privates
	let label = NSTextField()
	public override func view() -> NSView { return self.label }

	private var labelBinder: ValueBinder<String>?
	private var attributedLabelBinder: ValueBinder<NSAttributedString>?

	private var textColorBinder: ValueBinder<NSColor>?
	private lazy var textColorAnimator = NSColor.Animator()
}

// MARK: - Modifiers

public extension Label {
	/// The text to display in the label
	func label(_ label: String) -> Self {
		self.label.stringValue = label
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	func font(_ font: NSFont? = nil) -> Self {
		self.label.font = font
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
}

// MARK: - Bindings

public extension Label {
	/// Bind to the bindable string value
	/// - Parameters:
	///   - textValue: The value binding for the text to display
	/// - Returns: Self
	func bindLabel(_ textValue: ValueBinder<String>) -> Self {
		self.labelBinder = textValue
		textValue.register(self) { [weak self] newValue in
			self?.label.stringValue = newValue
		}
		return self
	}

	/// Bind to the bindable attributestring value
	/// - Parameters:
	///   - textValue: The value binding for the text to display
	/// - Returns: Self
	func bindAttributedLabel(_ attributedValue: ValueBinder<NSAttributedString>) -> Self {
		self.attributedLabelBinder = attributedValue
		attributedValue.register(self) { [weak self] newValue in
			self?.label.attributedStringValue = newValue
		}
		return self
	}

	/// Bind the text color
	func bindTextColor(_ colorBinder: ValueBinder<NSColor>, animated: Bool = false) -> Self {
		self.textColorBinder = colorBinder
		colorBinder.register(self) { [weak self] newValue in
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
