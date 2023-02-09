//
//  ComboBox.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AppKit.NSComboBox
import DSFValueBinders

/// Simple wrapper for NSPopupButton
///
/// Usage:
///
/// ```swift
/// let content = ValueBinder<[String]>(
///    ["red", "green", "blue", "yellow", "cyan", "magenta", "black"]
/// )
///
/// ComboBox(content: content)
/// ```
public class ComboBox: Control {
	/// Create a combo box
	/// - Parameters:
	///   - content: The content to display in the popdown menu
	///   - completes: A Boolean value indicating whether the combo box tries to complete what the user types
	///   - initialSelection: The initial selection in the menu
	///   - initialText: The initial text to display in the field
	///   - fixedNumberOfVisibleItems: If set, limits the maximum number of visible items in the menu to this value before scrolling.
	public init(
		content: ValueBinder<[String]>,
		completes: Bool = false,
		initialSelection: Int = -1,
		initialText: String? = nil,
		fixedNumberOfVisibleItems: Int? = nil
	) {
		self.content = content
		self.fixedNumberOfVisibleItems = fixedNumberOfVisibleItems

		self.combo.completes = completes
		self.combo.usesDataSource = false
		super.init()

		if let fixedNumberOfVisibleItems = fixedNumberOfVisibleItems {
			self.combo.numberOfVisibleItems = fixedNumberOfVisibleItems
		}

		self.combo.delegate = self
		(self.combo as NSTextField).delegate = self

		content.register { [weak self] newItemList in
			guard let self = `self` else { return }
			self.combo.removeAllItems()
			self.combo.addItems(withObjectValues: newItemList)

			if fixedNumberOfVisibleItems == nil {
				self.combo.numberOfVisibleItems = newItemList.count
			}
		}

		DispatchQueue.main.async { [unowned self] in
			self.asyncSetup(initialSelection: initialSelection, initialText: initialText)
		}
	}

	deinit {
		self.content.deregister(self)
		self.textValueBinder?.deregister(self)
		self.selectionBinder?.deregister(self)

		self.onEndEditing = nil
		self.onSelectionChange = nil
	}

	override public func view() -> NSView { return self.combo }
	fileprivate let combo = NSComboBox()
	fileprivate let content: ValueBinder<[String]>

	// Text Content binding
	private var textValueBinder: ValueBinder<String>?
	private var updateOnEndEditingOnly = false

	// Selection binding
	private var selectionBinder: ValueBinder<Int>?

	// How many items to display before scrolling?
	private let fixedNumberOfVisibleItems: Int?

	private var onEndEditing: ((String) -> Void)?
	private var onSelectionChange: ((Int) -> Void)?
}

private extension ComboBox {
	func asyncSetup(initialSelection: Int, initialText: String?) {
		// For some reason, these calls need to occur on the next run loop to take effect
		let validRange = (0 ..< self.content.wrappedValue.count)

		if validRange.contains(initialSelection) {
			self.combo.selectItem(at: initialSelection)
		}

		if let text = initialText {
			self.combo.stringValue = text
		}
		else {
			if validRange.contains(initialSelection) {
				self.combo.stringValue = self.content.wrappedValue[initialSelection]
			}
		}
	}
}

// MARK: - Bindings

public extension ComboBox {
	/// Bind the text content of the combobox to the value binder
	/// - Parameters:
	///   - updateOnEndEditingOnly: Only update the text when the field has ended editing (eg. when the user presses return or tabs away)
	///   - textValue: The value binder
	/// - Returns: Self
	func bindText(updateOnEndEditingOnly: Bool = false, _ textValue: ValueBinder<String>) -> Self {
		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		self.textValueBinder = textValue
		textValue.register { [weak self] newValue in
			self?.combo.stringValue = newValue
		}
		return self
	}

	/// Bind the selection of the combobox to the value binder
	/// - Parameters:
	///   - selectionBinder: The selection binder
	/// - Returns: Self
	func bindSelection(_ selectionBinder: ValueBinder<Int>) -> Self {
		self.selectionBinder = selectionBinder
		selectionBinder.register { [weak self] newValue in
			guard let `self` = self else { return }
			if (0 ..< self.content.wrappedValue.count).contains(newValue) {
				self.combo.selectItem(at: newValue)
			}
		}
		return self
	}
}

// MARK: - Actions

public extension ComboBox {
	/// Set a callback for when the combo box ends editing
	/// - Parameter block: The block to call
	/// - Returns: Self
	func onEndEditing(_ block: @escaping (String) -> Void) -> Self {
		self.onEndEditing = block
		return self
	}

	/// Set a callback for when the combo box ends editing
	/// - Parameter block: The block to call
	/// - Returns: Self
	func onSelectionChange(_ block: @escaping (Int) -> Void) -> Self {
		self.onSelectionChange = block
		return self
	}
}

extension ComboBox: NSTextFieldDelegate {
	public func controlTextDidBeginEditing(_: Notification) {
		// self.didBeginEditing?(self.label)
	}

	public func controlTextDidChange(_: Notification) {
		if !self.updateOnEndEditingOnly {
			self.textValueBinder?.wrappedValue = self.combo.stringValue
		}
	}

	public func controlTextDidEndEditing(_: Notification) {
		let newValue = self.combo.stringValue

		// Update the text binding value
		self.textValueBinder?.wrappedValue = newValue

		// Call the end editing block if it was specified
		self.onEndEditing?(newValue)
	}
}

extension ComboBox: NSComboBoxDelegate {
	public func comboBoxSelectionDidChange(_ notification: Notification) {
		// Update the text content
		if let newText = self.combo.objectValueOfSelectedItem as? String {
			self.textValueBinder?.wrappedValue = newText
		}

		// Update the selection binder
		let newSelection = self.combo.indexOfSelectedItem
		self.selectionBinder?.wrappedValue = newSelection
		self.onSelectionChange?(newSelection)
	}
}
