//
//  DSFAppKitBuilder+TextField.swift
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

import AppKit.NSTextField
import DSFValueBinders

/// An editable text element
///
/// Usage:
///
/// ```swift
/// let userName = ValueBinder("")
/// ...
/// TextField()
///    .placeholderText("Username")
///    .bindText(self.userName)
/// ```
public class TextField: Label {
	/// Create a text field element
	/// - Parameters:
	///   - label: The initial text for the text field
	///   - placeholderText: The placeholder text to use for the text field
	public init(
		_ label: String? = nil,
		_ placeholderText: String? = nil)
	{
		super.init(label)
		self.label.isEditable = true
		self.label.isBezeled = true
		self.label.placeholderString = placeholderText
		self.label.delegate = self
	}

	/// Create a text field element
	/// - Parameters:
	///   - text: A value binder for the label content
	///   - placeholderText: The placeholder text to use for the text field
	public init(
		_ text: ValueBinder<String>,
		_ placeholderText: String? = nil)
	{
		super.init(nil)
		self.label.isEditable = true
		self.label.isBezeled = true
		self.label.placeholderString = placeholderText
		self.label.delegate = self
		_ = self.bindText(text)
	}

	deinit {
		self.textValueBinder?.deregister(self)
	}

	// Privates

	// Block callbacks
	private var didBeginEditing: ((NSTextField) -> Void)?
	private var didEdit: ((NSTextField) -> Void)?
	private var didEndEditing: ((NSTextField) -> Void)?

	// Text Content binding
	private var textValueBinder: ValueBinder<String>?
	private var updateOnEndEditingOnly: Bool = false

	private var hasTextBinder: ValueBinder<Bool>?
}

// MARK: Modifiers

public extension TextField {
	/// Set the placeholder text for the text field
	func placeholderText(_ label: String) -> Self {
		self.label.placeholderString = label
		return self
	}

	/// Set continuous updates from the text field
	func isContinuous(_ b: Bool) -> Self {
		self.label.isContinuous = b
		return self
	}

	/// A Boolean value indicating whether excess text scrolls past the label's bounds
	func isScrollable(_ b: Bool) -> Self {
		self.label.cell?.isScrollable = b
		return self
	}
}

// MARK: Actions

public extension TextField {
	/// Block to call when the user starts editing the field
	func onStartEditing(_ block: @escaping (NSTextField) -> Void) -> Self {
		self.didBeginEditing = block
		return self
	}

	/// Block to call when the user modifies the content in the field
	func onEdit(_ block: @escaping (NSTextField) -> Void) -> Self {
		self.didEdit = block
		return self
	}

	/// Block to call when the user ends editing within the field
	func onEndEditing(_ block: @escaping (NSTextField) -> Void) -> Self {
		self.didEndEditing = block
		return self
	}
}

// MARK: Bindings

public extension TextField {
	/// Bind to the bindable string value
	/// - Parameters:
	///   - updateOnEndEditingOnly: If true, only updates the binding when the text field ends editing
	///   - textValue: The value binding for the text to display
	/// - Returns: Self
	func bindText(updateOnEndEditingOnly: Bool = false, _ textValue: ValueBinder<String>) -> Self {
		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		self.textValueBinder = textValue
		textValue.register { [weak self] newValue in
			self?.label.stringValue = newValue
		}
		return self
	}

	/// Binding whether the control has text in it
	/// - Parameters:
	///   - hasTextBinder: The value binding for indicating whether the field has text or not
	/// - Returns: Self
	func bindHasText(_ hasTextBinder: ValueBinder<Bool>) -> Self {
		self.hasTextBinder = hasTextBinder
		hasTextBinder.register { _ in
			// Nothing to do
		}
		return self
	}
}

// MARK: Text Field delegate methods

extension TextField: NSTextFieldDelegate {
	public func controlTextDidBeginEditing(_: Notification) {
		self.didBeginEditing?(self.label)
	}

	public func controlTextDidChange(_: Notification) {
		self.didEdit?(self.label)
		if !updateOnEndEditingOnly {
			self.textValueBinder?.wrappedValue = self.label.stringValue
			self.hasTextBinder?.wrappedValue = !self.label.stringValue.isEmpty
		}
	}

	public func controlTextDidEndEditing(_: Notification) {
		if updateOnEndEditingOnly {
			self.textValueBinder?.wrappedValue = self.label.stringValue
			self.hasTextBinder?.wrappedValue = !self.label.stringValue.isEmpty
		}
		self.didEndEditing?(self.label)
	}
}
