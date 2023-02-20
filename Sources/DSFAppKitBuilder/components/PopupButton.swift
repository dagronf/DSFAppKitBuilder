//
//  PopupButton.swift
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

import AppKit.NSPopUpButton

import DSFMenuBuilder
import DSFValueBinders

/// Wrapper for NSPopupButton
///
/// Usage:
///
/// ```swift
/// PopupButton {
///    MenuItem("Weekly")
///    MenuItem("Monthly")
///    Separator()
///    MenuItem("Yearly")
/// }
/// .onChange { popupIndex in
///    // do something when the selection changes
/// }
/// ```
public class PopupButton: Control {

	/// Create a PopupButton instance, using DSFMenuBuilder to build the popup button menu content
	/// - Parameters:
	///   - pullsDown: A Boolean value indicating whether the button displays a pull-down or pop-up menu.
	///   - builder: The result builder for the popup buttons menu content
	public convenience init(
		pullsDown: Bool = false,
		bezelStyle: NSButton.BezelStyle? = nil,
		@MenuBuilder builder: () -> [AnyMenuItem]
	) {
		self.init(
			pullsDown: pullsDown,
			bezelStyle: bezelStyle,
			content: builder()
		)
	}

	deinit {
		self.selectionBinder?.deregister(self)
		self.titleBinder?.deregister(self)
	}

	// Private

	public override func view() -> NSView { return self.popupButton }
	fileprivate let popupButton = NSPopUpButton()
	private let content: [AnyMenuItem]

	private var selectionBinder: ValueBinder<Int>?
	private var selectionChangeBlock: ((Int) -> Void)?
	private var titleBinder: ValueBinder<String>?

	internal init(
		pullsDown: Bool = false,
		bezelStyle: NSButton.BezelStyle? = nil,
		content: [AnyMenuItem]
	) {
		self.content = content
		super.init()

		self.popupButton.pullsDown = pullsDown

		if let bezelStyle = bezelStyle {
			self.popupButton.bezelStyle = bezelStyle
		}

		self.popupButton.target = self
		self.popupButton.action = #selector(selectionChanged(_:))

		let menu = Menu(content: content).menu
		self.popupButton.menu = menu
	}
}

// MARK: - Modifiers

public extension PopupButton {
	/// Set the initially selected popup item
	func selectItem(at index: Int) -> Self {
		self.popupButton.selectItem(at: index)
		self.selectionBinder?.wrappedValue = index
		return self
	}
}

// MARK: - Action

public extension PopupButton {
	/// Set the block to be called when the selection changes
	func onChange(_ block: @escaping (Int) -> Void) -> Self {
		self.selectionChangeBlock = block
		return self
	}
}

// MARK: - Binding

public extension PopupButton {
	/// Bind the selection
	func bindSelection(_ selectionBinder: ValueBinder<Int>) -> Self {
		self.selectionBinder = selectionBinder
		selectionBinder.register { [weak self] newValue in
			self?.popupButton.selectItem(at: newValue)
		}
		return self
	}

	func bindTitle(_ titleBinder:  ValueBinder<String>) -> Self {
		self.titleBinder = titleBinder
		titleBinder.register(self) { [weak self] newValue in
			self?.popupButton.title = newValue
		}
		return self
	}
}

// MARK: Private

private extension PopupButton {

	var selectedIndex: Int {
		return self.popupButton.indexOfSelectedItem
	}

	@objc private func selectionChanged(_: Any) {
		self.selectionChangeBlock?(self.selectedIndex)

		// Tell the binder to update
		self.selectionBinder?.wrappedValue = self.selectedIndex
	}
}

/// A popup button that mimics the macOS Action (Gear) Button
///
/// Note that the selection index for the SystemStylePopoverButton is 1 based,
/// so if you use `bindSelection` the indexing starts from 1
public class SystemStylePopoverButton: PopupButton {
	/// Create a gear popup
	/// - Parameters:
	///   - image: The image to use, or nil to use the standard macOS action template
	///   - bezelStyle: The style of popup button to use
	///   - isBordered: Does the control draw the bezel?
	///   - builder: The menu builder
	public convenience init(
		image: NSImage = SystemStylePopoverButton.SystemGearImage,
		bezelStyle: NSButton.BezelStyle? = nil,
		isBordered: Bool = true,
		@MenuBuilder builder: () -> [AnyMenuItem]
	) {
		self.init(bezelStyle: bezelStyle, isBordered: isBordered, content: builder())
	}

	/// Create a gear popup
	/// - Parameters:
	///   - image: The image to use, or nil to use the standard macOS action template
	///   - bezelStyle: The style of popup button to use
	///   - isBordered: Does the control draw the bezel?
	///   - content: The menu items to provide in the popup
	public init(
		image: NSImage = SystemStylePopoverButton.SystemGearImage,
		bezelStyle: NSButton.BezelStyle? = nil,
		isBordered: Bool = true,
		content: [AnyMenuItem]
	) {
		super.init(pullsDown: true, bezelStyle: bezelStyle, content: content)
		let actionItem = NSMenuItem()
		actionItem.image = image
		self.popupButton.menu?.insertItem(actionItem, at: 0)
		let cell = self.popupButton.cell as? NSButtonCell
		cell?.imagePosition = .imageOnly
		cell?.bezelStyle = .texturedRounded
		self.popupButton.isBordered = isBordered
	}

	public static let SystemGearImage = NSImage(named: NSImage.actionTemplateName)!
}
