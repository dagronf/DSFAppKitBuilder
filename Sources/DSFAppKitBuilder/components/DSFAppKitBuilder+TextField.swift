//
//  DSFAppKitBuilder+TextField.swift
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

/// An editable text control
public class TextField: Label {
	public init(
		tag: Int? = nil,
		_ label: String? = nil,
		_ placeholderText: String? = nil)
	{
		super.init(tag: tag, label)
		self.label.isEditable = true
		self.label.isBezeled = true
		self.label.placeholderString = placeholderText
		self.label.delegate = self
	}

	// Privates

	// Block callbacks
	private var didBeginEditing: ((NSTextField) -> Void)?
	private var didEdit: ((NSTextField) -> Void)?
	private var didEndEditing: ((NSTextField) -> Void)?

	// Text Content binding
	private lazy var textFieldBinder = Bindable<String>()
	private var updateOnEndEditingOnly: Bool = false
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
	/// Bind the text content to a keypath
	func bindText<TYPE>(updateOnEndEditingOnly: Bool = false, _ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		self.textFieldBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.label.stringValue = newValue
		})
		self.textFieldBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
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
		if !updateOnEndEditingOnly && self.textFieldBinder.isActive {
			self.textFieldBinder.setValue(self.label.stringValue)
		}
	}

	public func controlTextDidEndEditing(_: Notification) {
		self.didEndEditing?(self.label)
		if updateOnEndEditingOnly && self.textFieldBinder.isActive {
			self.textFieldBinder.setValue(self.label.stringValue)
		}
	}
}
