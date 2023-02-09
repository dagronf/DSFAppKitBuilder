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

import AppKit
import DSFValueBinders
import DSFComboButton

/// An NSComboButton that uses DSFComboButton for macOS < 13
public class ComboButton: Control {

	public init(
		style: DSFComboButton.Style,
		_ title: String,
		image: NSImage? = nil,
		menu: NSMenu?,
		_ onAction: (() -> Void)? = nil
	) {
		self.action = onAction
		self.menu = menu ?? NSMenu()

		super.init()

		self.comboButton.title = title
		self.comboButton.image = image
		self.comboButton.styleWrapper = style
		self.comboButton.menuWrapper = self.menu
		self.comboButton.target = self
		self.comboButton.action = #selector(buttonAction(_:))
		self.comboButton.menuWrapper.delegate = self
	}

	deinit {
		self.titleBinder = nil
	}

	override public func view() -> NSView { return self.comboButton }

#if swift(>=5.7)
	private lazy var comboButton: ComboButtonWrapper = {
		if #available(macOS 13, *) {
			return NSComboButton()
		}
		else {
			return DSFComboButton()
		}
	}()
#else
	private lazy var comboButton = DSFComboButton()
#endif

	private let menu: NSMenu
	private var action: (() -> Void)?
	private var titleBinder: ValueBinder<String>?
	private var imageBinder: ValueBinder<NSImage?>?

	private var menuBuilder: (() -> NSMenu?)?
}

extension ComboButton {
	@objc func buttonAction(_ sender: Any) {
		self.action?()
	}
}

public extension ComboButton {
	/// Called when the menu is about to be displayed. You provide the menu that should be presented
	func generateMenu(_ menuBuilder: @escaping () -> NSMenu?) -> Self {
		self.menuBuilder = menuBuilder
		return self
	}
}

extension ComboButton: NSMenuDelegate {
	public func menuNeedsUpdate(_ menu: NSMenu) {
		if let menuBuilder = menuBuilder,
			let newMenu = menuBuilder()
		{
			// Transfer the menu items from the returned one to our internal menu
			let allItems = newMenu.items
			newMenu.removeAllItems()
			menu.items = allItems
		}
	}
}

public extension ComboButton {
	/// Bind the title
	func bindTitle(_ titleBinder: ValueBinder<String>) -> Self {
		self.titleBinder = titleBinder
		titleBinder.register { [weak self] newValue in
			self?.comboButton.title = newValue
		}
		return self
	}
	/// Bind the image
	func bindImage(_ imageBinder: ValueBinder<NSImage?>) -> Self {
		self.imageBinder = imageBinder
		imageBinder.register { [weak self] newValue in
			self?.comboButton.image = newValue
		}
		return self
	}
}

// MARK: - Compliance

protocol ComboButtonWrapper: NSView {
	var title: String { get set }
	var image: NSImage? { get set }
	var action: Selector? { get set }
	var target: AnyObject? { get set }
	var menuWrapper: NSMenu { get set }
	var styleWrapper: DSFComboButton.Style { get set }
}

#if swift(>=5.7)
@available(macOS 13.0, *)
extension NSComboButton: ComboButtonWrapper {
	var styleWrapper: DSFComboButton.Style {
		get { DSFComboButton.Style(rawValue: self.style.rawValue)! }
		set { self.style = NSComboButton.Style(rawValue: newValue.rawValue)! }
	}

	var menuWrapper: NSMenu {
		get { self.menu }
		set { self.menu = newValue }
	}
}
#endif

extension DSFComboButton: ComboButtonWrapper {
	var menuWrapper: NSMenu {
		get { self.menu ?? NSMenu() }
		set { self.menu = newValue }
	}
	var styleWrapper: DSFComboButton.Style {
		get { self.style }
		set { self.style = newValue }
	}
}


#if DEBUG && canImport(SwiftUI)
import DSFMenuBuilder
private let menu1: NSMenu = NSMenu {
	MenuItem("one")
		.onAction { Swift.print("one") }
}
private let menu2: NSMenu = NSMenu {
	MenuItem("two")
		.onAction { Swift.print("two") }
}

import SwiftUI
@available(macOS 10.15, *)
struct ComboButtonPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			HStack {
				VStack(alignment: .leading) {
					Label("Default")
					ComboButton(style: .split, "Split Style", menu: menu1)
					ComboButton(style: .unified, "Unified Style", menu: menu2)
				}
				VStack {
					Label("Disabled") //.font(.headline)
					ComboButton(style: .split, "Split Style", menu: nil)
						.isEnabled(false)
					ComboButton(style: .unified, "Unified Style", menu: nil)
						.isEnabled(false)
					ComboButton(style: .unified, "Unified Style", menu: nil)
						.bindIsHidden(ValueBinder<Bool>(true))
				}
			}
			.SwiftUIPreview()
		}
		.padding()
		.frame(width: 400)
	}
}
#endif

