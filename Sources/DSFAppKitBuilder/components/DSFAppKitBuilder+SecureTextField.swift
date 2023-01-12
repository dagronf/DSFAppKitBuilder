//
//  DSFAppKitBuilder+SecureTextField.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

import AppKit.NSSecureTextField
import DSFValueBinders

/// A wrapper for NSSecureTextField
///
/// Usage:
///
/// ```swift
/// let password = ValueBinder("")
/// ...
/// SecureTextField()
///    .placeholderText("Password")
///    .bindSecureText(self.password)
/// ```
public class SecureTextField: Control {
	/// Create a secure text field
	/// - Parameters:
	///   - placeholderText: The placeholder text to display
	///   - updateOnEndEditingOnly: If true, only updates binders when the field finishes editing
	public init(placeholderText: String? = nil,
					updateOnEndEditingOnly: Bool = true) {
		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		super.init()
		self.secureTextField.delegate = self
		self.secureTextField.placeholderString = placeholderText
	}

	deinit {
		self.secureTextBinder?.deregister(self)
	}

	private let secureTextField = NSSecureTextField()
	public override func view() -> NSView { return self.secureTextField }

	private var secureTextBinder: ValueBinder<String>?
	private let updateOnEndEditingOnly: Bool
}

// MARK: - Modifiers

public extension SecureTextField {
	/// The font used to draw text in the receiver’s cell.
	func font(_ font: NSFont? = nil) -> Self {
		self.secureTextField.font = font
		return self
	}

	/// The color of the text field’s content.
	func textColor(_ textColor: NSColor? = nil) -> Self {
		self.secureTextField.textColor = textColor
		return self
	}

	/// A Boolean value that controls whether the text field draws a solid black border around its contents.
	func isBordered(_ s: Bool) -> Self {
		self.secureTextField.isBordered = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a bezeled background around its contents.
	func isBezeled(_ s: Bool) -> Self {
		self.secureTextField.isBezeled = s
		return self
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	func drawsBackground(_ s: Bool) -> Self {
		self.secureTextField.drawsBackground = s
		return self
	}
}

// MARK: - Bindings

public extension SecureTextField {
	/// Bind the field's value to the ValueBinder
	/// - Parameters:
	///   - secureTextBinder: The binding for the secure text
	/// - Returns: Self
	func bindSecureText(_ secureTextBinder: ValueBinder<String>) -> Self {
		self.secureTextBinder = secureTextBinder
		secureTextBinder.register { [weak self] newValue in
			self?.secureTextField.stringValue = newValue
		}
		return self
	}
}

// MARK: - SecureTextField delegates

extension SecureTextField: NSTextFieldDelegate {
	public func controlTextDidChange(_: Notification) {
		if !updateOnEndEditingOnly {
			self.secureTextBinder?.wrappedValue = self.secureTextField.stringValue
		}
	}

	public func controlTextDidEndEditing(_: Notification) {
		if updateOnEndEditingOnly {
			self.secureTextBinder?.wrappedValue = self.secureTextField.stringValue
		}
	}
}
