//
//  DSFAppKitBuilder+Button.swift
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

import AppKit.NSButton

/// An NSButton wrapper
///
/// Usage:
///
/// ```swift
/// Button(title: "Title") { [weak self] newState in
///    // button action code
/// }
/// ```
public class Button: Control {

	/// Create a button
	/// - Parameters:
	///   - title: The button title
	///   - type: The type of button
	///   - bezelStyle: The bezel to use for the button
	///   - allowMixedState: Does the button allow mixed state?
	///   - onChange: The block to call when the state of the button changes
	public init(
		title: String,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle: NSButton.BezelStyle = .rounded,
		allowMixedState: Bool = false,
		_ onChange: ((NSButton.StateValue) -> Void)? = nil
	) {
		super.init()
		self.button.title = title
		self.button.bezelStyle = bezelStyle
		self.button.setButtonType(type)
		self.button.allowsMixedState = allowMixedState

		self.button.target = self
		self.button.action = #selector(self.performAction(_:))

		if let onChange = onChange {
			self.action = onChange
		}
	}

	deinit {
		self.onOffBinder?.detachAll()
		self.stateBinder?.detachAll()
		self.titleBinder?.detachAll()
		self.alternateTitleBinder?.detachAll()
	}

	// Privates

	fileprivate let button = NSButton()
	public override func view() -> NSView { return self.button }
	private var action: ((NSButton.StateValue) -> Void)?

	private var onOffBinder: ValueBinder<Bool>?
	private var stateBinder: ValueBinder<NSControl.StateValue>?
	private var titleBinder: ValueBinder<String>?
	private var alternateTitleBinder: ValueBinder<String>?
}

// MARK: - Modifiers

public extension Button {

	/// Set the button's title
	func title(_ title: String) -> Self {
		self.button.stringValue = title
		return self
	}

	/// The title that the button displays when the button is in an on state.
	func alternateTitle(_ title: String) -> Self {
		self.button.alternateTitle = title
		return self
	}

	/// Set the image that appears on the button when it’s in an off state
	func image(
		_ image: NSImage,
		imagePosition: NSControl.ImagePosition = .imageLeading,
		imageScaling: NSImageScaling? = nil,
		imageHugsTitle: Bool? = nil
	) -> Self {
		self.button.image = image
		self.button.imagePosition = imagePosition
		if let i = imageHugsTitle { self.button.imageHugsTitle = i }
		if let i = imageScaling { self.button.imageScaling = i }
		return self
	}

	/// Set the image that appears on the button when it’s in an on state
	func alternateImage(_ image: NSImage) -> Self {
		self.button.alternateImage = image
		return self
	}

	/// A Boolean value that determines whether the button has a border.
	func isBordered(_ isBordered: Bool) -> Self {
		self.button.isBordered = isBordered
		return self
	}

	/// Set the button's initial state
	func state(_ state: NSControl.StateValue) -> Self {
		self.button.state = state
		return self
	}

	/// Set the button's font
	func font(_ font: NSFont) -> Self {
		self.button.font = font
		return self
	}
}

// MARK: - Actions

public extension Button {
	/// Set a block to be called when the button state changes
	///
	/// Passes the new button state to the callback block
	func onChange(_ onChange: @escaping ((NSButton.StateValue) -> Void)) -> Self {
		self.action = onChange
		return self
	}

	@objc private func performAction(_ item: NSButton) {
		self.action?(item.state)

		/// Tell the binders to update
		self.onOffBinder?.wrappedValue = (item.state == .off ? false : true)
		self.stateBinder?.wrappedValue = item.state
	}
}

// MARK: - Bindings

public extension Button {
	/// Bind the title to a keypath
	func bindTitle(_ titleBinder: ValueBinder<String>) -> Self {
		self.titleBinder = titleBinder
		titleBinder.register(self) { [weak self] newValue in
			self?.button.title = newValue
		}
		return self
	}

	/// Bind the alternatetitle to a keypath
	func bindAlternateTitle(_ alternateTitleBinder: ValueBinder<String>) -> Self {
		self.alternateTitleBinder = alternateTitleBinder
		alternateTitleBinder.register(self) { [weak self] newValue in
			self?.button.alternateTitle = newValue
		}
		return self
	}

	/// Bind the state to a keypath
	func bindState(_ stateBinder: ValueBinder<NSControl.StateValue>) -> Self {
		self.stateBinder = stateBinder
		stateBinder.register(self) { [weak self] newValue in
			self?.button.state = newValue
		}
		return self
	}

	/// Bind on/off state to a keypath
	func bindOnOffState(_ onOffBinder: ValueBinder<Bool>) -> Self {
		self.onOffBinder = onOffBinder
		onOffBinder.register(self) { [weak self] newValue in
			self?.button.state = newValue ? .on : .off
		}
		return self
	}
}
