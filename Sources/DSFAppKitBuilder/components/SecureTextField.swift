//
//  SecureTextField.swift
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

import AppKit.NSSecureTextField
import DSFValueBinders

/// A wrapper for NSSecureTextField
///
/// Usage:
///
/// ```swift
/// let password = ValueBinder("")
/// ...
/// SecureTextField(self.password)
///    .placeholderText("Password")
///    .bindSecureText(self.password)
/// ```
public class SecureTextField: Control {
	/// Create a secure text field
	/// - Parameters:
	///   - initialText: The initial text for the control
	///   - placeholderText: The placeholder text to display
	///   - updateOnEndEditingOnly: If true, updates binders only when the field finishes editing
	public init(
		_ initialText: String? = nil,
		placeholderText: String? = nil,
		updateOnEndEditingOnly: Bool = true
	) {
		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		super.init()
		if let initialText = initialText {
			self.secureTextField.stringValue = initialText
		}
		self.secureTextField.delegate = self
		self.secureTextField.placeholderString = placeholderText
	}

	/// Create a secure text field
	/// - Parameters:
	///   - secureBinder: A ValueBinder for the content of the field
	///   - placeholderText: The placeholder text to display
	///   - updateOnEndEditingOnly: If true, updates binders only when the field finishes editing
	public init(
		_ secureBinder: ValueBinder<String>,
		placeholderText: String? = nil,
		updateOnEndEditingOnly: Bool = true
	) {
		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		super.init()
		self.secureTextField.delegate = self
		self.secureTextField.placeholderString = placeholderText

		self.bindSecureText(secureBinder)
	}

	deinit {
		self.onChangeBlock = nil
		self.secureTextBinder?.deregister(self)
	}

	private let secureTextField = PaddableSecureTextField()
	public override func view() -> NSView { return self.secureTextField }
	private var secureTextBinder: ValueBinder<String>?
	private let updateOnEndEditingOnly: Bool
	private var onChangeBlock: ((String) -> Void)?
}

// MARK: - Modifiers

public extension SecureTextField {
	/// The color of the text field’s content.
	@discardableResult func textColor(_ textColor: NSColor? = nil) -> Self {
		self.secureTextField.textColor = textColor
		return self
	}

	/// A Boolean value that controls whether the text field draws a solid black border around its contents.
	@discardableResult func isBordered(_ s: Bool) -> Self {
		self.secureTextField.isBordered = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a bezeled background around its contents.
	@discardableResult func isBezeled(_ s: Bool) -> Self {
		self.secureTextField.isBezeled = s
		return self
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	@discardableResult func drawsBackground(_ s: Bool) -> Self {
		self.secureTextField.drawsBackground = s
		return self
	}

	/// Set the placeholder text
	@discardableResult func placeholderText(_ text: String) -> Self {
		self.secureTextField.placeholderString = text
		return self
	}
}

// MARK: - Actions

public extension SecureTextField {
	/// Supply a block that will get called when the text in the field changes
	@discardableResult func onChange(_ changeBlock: @escaping (String) -> Void) -> Self {
		self.onChangeBlock = changeBlock
		return self
	}
}

// MARK: - Bindings

public extension SecureTextField {
	/// Bind the field's value to the ValueBinder
	/// - Parameters:
	///   - secureTextBinder: The binding for the secure text
	/// - Returns: Self
	@discardableResult func bindSecureText(_ secureTextBinder: ValueBinder<String>) -> Self {
		self.secureTextBinder = secureTextBinder
		secureTextBinder.register { [weak self] newValue in
			self?.secureTextField.stringValue = newValue
		}
		return self
	}
}

public extension SecureTextField {
	/// Apply padding to the text field
	func labelPadding(_ value: CGFloat) -> Self {
		self.secureTextField.edgeInsets = NSEdgeInsets(edgeInset: value)
		return self
	}

	/// Apply padding to the text field
	func labelPadding(_ value: NSEdgeInsets) -> Self {
		self.secureTextField.edgeInsets = value
		return self
	}
}

// MARK: - SecureTextField delegates

extension SecureTextField: NSTextFieldDelegate {
	public func controlTextDidChange(_: Notification) {
		if !updateOnEndEditingOnly {
			let str = self.secureTextField.stringValue
			self.secureTextBinder?.wrappedValue = str
			self.onChangeBlock?(str)
		}
	}

	public func controlTextDidEndEditing(_: Notification) {
		if updateOnEndEditingOnly {
			let str = self.secureTextField.stringValue
			self.secureTextBinder?.wrappedValue = str
			self.onChangeBlock?(str)
		}
	}
}
