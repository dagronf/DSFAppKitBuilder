//
//  Button.swift
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

import AppKit.NSButton
import DSFValueBinders

/// An NSButton wrapper.
///
/// You can supply a custom NSButton overload via the template parameter
///
/// Usage:
///
/// The standard NSButton
///
/// ```swift
/// Button(title: "Title") { [weak self] newState in
///    // button action code
/// }
/// ```
///
/// A custom NSButton class type
///
/// ```swift
/// Button(title: "Title", customButton: AccentColorButton()) { [weak self] newState in
///    // button action code
/// }
/// ```
///
public class Button: Control {
	/// The button's action type
	public typealias ButtonAction = (NSButton.StateValue) -> Void

	/// Create a button
	/// - Parameters:
	///   - title: The button title
	///   - type: The type of button
	///   - bezelStyle: The bezel to use for the button
	///   - allowMixedState: Does the button allow mixed state?
	///   - customButton: (Optional) Provide a custom button instance
	///   - customButtonCell: (Optional) Provide a custom button cell
	///   - onChange: The block to call when the state of the button changes
	public init(
		title: String,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle: NSButton.BezelStyle = .rounded,
		allowMixedState: Bool = false,
		customButton: NSButton? = nil,
		customButtonCell: NSButtonCell? = nil,
		_ onChange: ButtonAction? = nil
	) {
		self.button = {
			if let customButtonCell = customButtonCell {
				let b = NSButton()
				b.cell = customButtonCell
				return b
			}
			else if let customButton = customButton {
				return customButton
			}
			else {
				return NSButton()
			}
		}()
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

	/// Create a button
	/// - Parameters:
	///   - image: The button's image
	///   - type: The type of button
	///   - bezelStyle: The bezel to use for the button
	///   - allowMixedState: Does the button allow mixed state?
	///   - customButton: (Optional) Provide a custom button instance
	///   - customButtonCell: (Optional) Provide a custom button cell
	///   - onChange: The block to call when the state of the button changes
	public init(
		image: NSImage,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle: NSButton.BezelStyle = .rounded,
		allowMixedState: Bool = false,
		customButton: NSButton? = nil,
		customButtonCell: NSButtonCell? = nil,
		_ onChange: ButtonAction? = nil
	) {
		self.button = {
			if let customButtonCell = customButtonCell {
				let b = NSButton()
				b.cell = customButtonCell
				return b
			}
			else if let customButton = customButton {
				return customButton
			}
			else {
				return NSButton()
			}
		}()
		super.init()
		self.button.image = image
		self.button.imagePosition = .imageOnly
		self.button.imageScaling = .scaleProportionallyDown

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
		self.action = nil
		self.onOffBinder?.deregister(self)
		self.stateBinder?.deregister(self)
		self.titleBinder?.deregister(self)
		self.alternateTitleBinder?.deregister(self)
		self.groupBinder?.deregister(self)
	}

	// Privates

	internal let button: NSButton
	override public func view() -> NSView { return self.button }
	private var action: ButtonAction?

	private var onOffBinder: ValueBinder<Bool>?
	private var stateBinder: ValueBinder<NSControl.StateValue>?
	private var titleBinder: ValueBinder<String>?
	private var alternateTitleBinder: ValueBinder<String>?
	private var groupBinder: ValueBinder<RadioBinding>?

	override public var debugDescription: String {
		return "Button[title='\(self.button.title)'"
	}

	@objc private func performAction(_ item: NSButton) {
		self.action?(item.state)

		if let group = self.groupBinder {
			group.wrappedValue.selectedID = self.id
			group.valueDidChange()
		}

		/// Tell the binders to update
		self.onOffBinder?.wrappedValue = (item.state == .off ? false : true)
		self.stateBinder?.wrappedValue = item.state
	}
}

// MARK: - Modifiers

public extension Button {
	/// Set the button's title
	@discardableResult func title(_ title: String) -> Self {
		self.button.stringValue = title
		return self
	}

	/// The title that the button displays when the button is in an on state.
	@discardableResult func alternateTitle(_ title: String) -> Self {
		self.button.alternateTitle = title
		return self
	}

	/// Set the image that appears on the button when it’s in an off state
	@discardableResult func image(
		_ image: NSImage,
		imagePosition: NSControl.ImagePosition? = nil,
		imageScaling: NSImageScaling? = nil,
		imageHugsTitle: Bool? = nil
	) -> Self {
		self.button.image = image
		if let i = imagePosition {
			self.button.imagePosition = i
		}
		if let i = imageHugsTitle {
			self.button.imageHugsTitle = i
		}
		if let i = imageScaling { self.button.imageScaling = i }
		return self
	}

	/// Set the image that appears on the button when it’s in an on state
	@discardableResult func alternateImage(_ image: NSImage) -> Self {
		self.button.alternateImage = image
		return self
	}

	/// A Boolean value that determines whether the button has a border.
	@discardableResult func isBordered(_ isBordered: Bool) -> Self {
		self.button.isBordered = isBordered
		return self
	}

	/// Set the button's initial state
	@discardableResult func state(_ state: NSControl.StateValue) -> Self {
		self.button.state = state
		return self
	}

	/// Set the bezel color for the button.
	///
	/// Note: Not all button types support bezel colors.
	@discardableResult func bezelColor(_ color: NSColor) -> Self {
		self.button.bezelColor = color
		return self
	}

	/// Applies a tint color to template image and text content, in combination with other theme-appropriate effects. Only applicable to borderless buttons
	///
	/// Only applicable on 10.14 and later. 10.13 will ignore calls.
	@discardableResult func contentTintColor(_ color: NSColor) -> Self {
		if #available(macOS 10.14, *) {
			self.button.contentTintColor = color
		}
		return self
	}

	/// Indicate whether the button’s action has a destructive effect.
	///
	/// Only takes effect on macOS 11 and later
	@discardableResult func hasDestructiveAction(_ isDestructive: Bool) -> Self {
		if #available(macOS 11.0, *) {
			button.hasDestructiveAction = isDestructive
		}
		return self
	}
}

// MARK: - Actions

public extension Button {
	/// Set a block to be called when the button state changes
	///
	/// Passes the new button state to the callback block
	func onChange(_ onChange: @escaping ButtonAction) -> Self {
		self.action = onChange
		return self
	}
}

// MARK: - Bindings

public extension Button {
	/// Bind the title
	@discardableResult func bindTitle(_ titleBinder: ValueBinder<String>) -> Self {
		self.titleBinder = titleBinder
		titleBinder.register { [weak self] newValue in
			self?.button.title = newValue
		}
		return self
	}

	/// Bind the alternatetitle
	@discardableResult func bindAlternateTitle(_ alternateTitleBinder: ValueBinder<String>) -> Self {
		self.alternateTitleBinder = alternateTitleBinder
		alternateTitleBinder.register { [weak self] newValue in
			self?.button.alternateTitle = newValue
		}
		return self
	}

	/// Bind the state
	@discardableResult func bindState(_ stateBinder: ValueBinder<NSControl.StateValue>) -> Self {
		self.stateBinder = stateBinder
		stateBinder.register { [weak self] newValue in
			self?.button.state = newValue
		}
		return self
	}

	/// Bind on/off state
	@discardableResult func bindOnOffState(_ onOffBinder: ValueBinder<Bool>) -> Self {
		self.onOffBinder = onOffBinder
		onOffBinder.register { [weak self] newValue in
			self?.button.state = newValue ? .on : .off
		}
		return self
	}
}

public extension Button {
	/// Link buttons together into a radio group style button collection, with only one 'on' at any time
	/// - Parameters:
	///   - groupBinder: The binding object
	///   - initialSelection: If true, sets this button to be initially selected
	/// - Returns: self
	func bindRadioGroup(_ groupBinder: ValueBinder<RadioBinding>, initialSelection: Bool = false) -> Self {
		self.groupBinder = groupBinder
		groupBinder.wrappedValue.radioButtons.append(self)
		groupBinder.register { [weak self] newValue in
			guard let `self` = self else { return }
			self.button.state = (newValue.selectedID == self.id) ? .on : .off
		}

		if initialSelection {
			groupBinder.wrappedValue.selectedID = self.id
			groupBinder.valueDidChange()
		}
		return self
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ButtonPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				Grid(columnSpacing: 20) {
					GridRow(rowAlignment: .firstBaseline) {
						Label("Bezel Style").font(.title2)
						Label("Preview").font(.title2)
						Label("Var Height").font(.title2)
						Label("Multiline").font(.title2)
						Label("Bezel Color?").font(.title2)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".circular").font(.monospaced)
						Button(title: "", bezelStyle: .circular)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".disclosure").font(.monospaced)
						Button(title: "", bezelStyle: .disclosure)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".helpButton").font(.monospaced)
						Button(title: "", bezelStyle: .helpButton)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".inline").font(.monospaced)
						Button(title: "My Button", bezelStyle: .inline)
						Label("✅")
						Label("✅")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".recessed").font(.monospaced)
						Button(title: "My Button", bezelStyle: .recessed)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".regularSquare").font(.monospaced)
						Button(title: "My Button", bezelStyle: .regularSquare)
						Label("✅")
						Label("✅")
						Button(title: "My Button", bezelStyle: .regularSquare)
							.bezelColor(NSColor.systemRed)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".rounded").font(.monospaced)
						Button(title: "My Button", bezelStyle: .rounded)
						Label("-")
						Label("-")
						Button(title: "My Button", bezelStyle: .rounded)
							.bezelColor(NSColor.systemRed)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".roundedDisclosure").font(.monospaced)
						Button(title: "", bezelStyle: .roundedDisclosure)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".roundRect").font(.monospaced)
						Button(title: "My Button", bezelStyle: .roundRect)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".shadowlessSquare").font(.monospaced)
						Button(title: "My Button", bezelStyle: .shadowlessSquare)
						Label("-")
						Label("✅")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".smallSquare").font(.monospaced)
						Button(title: "My Button", bezelStyle: .smallSquare)
						Label("✅")
						Label("✅")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".texturedRounded").font(.monospaced)
						Button(title: "My Button", bezelStyle: .texturedRounded)
						Label("-")
						Label("-")
						Label("-")
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".texturedSquare").font(.monospaced)
						Button(title: "My Button", bezelStyle: .texturedSquare)
						Label("-")
						Label("✅")
						Label("-")
					}
				}
				.columnFormatting(xPlacement: .center, atColumn: 2)
				.columnFormatting(xPlacement: .center, atColumn: 3)
				.columnFormatting(xPlacement: .center, atColumn: 4)
				.cellFormatting(xPlacement: .center, atRowIndex: 0, columnIndex: 2)
				.cellFormatting(xPlacement: .center, atRowIndex: 0, columnIndex: 3)
				.cellFormatting(xPlacement: .center, atRowIndex: 0, columnIndex: 4)
				HDivider()

				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}

@available(macOS 11, *)
struct ButtonContentTintPreview: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			Group(layoutType: .center, visualEffect: .init(VisualEffect(material: .hudWindow))) {
				HStack {
					Label("Button Content tint color -> ")
					Button(title: "I'm green!").isBordered(false)
						.font(.title3)
						.image(
							NSImage(systemSymbolName: "apple.logo", accessibilityDescription: nil)!,
							imagePosition: .imageLeading
						)
						.contentTintColor(NSColor.systemGreen)
						.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					Button(title: "I'm red!").isBordered(false)
						.font(.title3)
						.contentTintColor(NSColor.systemRed)
						.image(
							NSImage(systemSymbolName: "apple.logo", accessibilityDescription: nil)!,
							imagePosition: .imageAbove
						)
						.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					Button(title: "I'm blue").isBordered(false)
						.font(.title3)
						.contentTintColor(NSColor.systemBlue)
						.image(
							NSImage(systemSymbolName: "apple.logo", accessibilityDescription: nil)!,
							imagePosition: .imageOnly,
							imageScaling: .scaleProportionallyUpOrDown
						)
						.border(width: 0.5, color: NSColor.quaternaryLabelColor)
				}
			}
			.SwiftUIPreview()
		}
	}
}
#endif
