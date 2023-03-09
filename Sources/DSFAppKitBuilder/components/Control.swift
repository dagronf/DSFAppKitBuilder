//
//  Control.swift
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

import AppKit.NSControl
import DSFValueBinders

/// A DSL Element that is a control (ie. it is interactive in some way, like a button)
public class Control: Element {
	// Block the initializer so can't be created outside the package
	internal override init() {
		super.init()
	}

	deinit {
		self.isEnabledBinder?.deregister(self)
		self.fontBinder?.deregister(self)

		if self.hasDynamicFont {
			DynamicFontService.shared.deregister(self)
		}
	}

	@objc open func onControlSizeChange(_ controlSize: NSControl.ControlSize) {
		// Do nothing
	}

	/// Binding for isEnabled
	public func bindIsEnabled(_ enabledBinding: ValueBinder<Bool>) -> Self {
		enabledBinding.register { [weak self] newValue in
			self?.control.isEnabled = newValue
		}
		self.isEnabledBinder = enabledBinding
		return self
	}

	// Private
	private var isEnabledBinder: ValueBinder<Bool>?
	private var fontBinder: ValueBinder<NSFont?>?
	private var control: NSControl { return view() as! NSControl }
	private var hasDynamicFont: Bool = false
}

// MARK: - Modifiers

public extension Control {
	enum ControlSize: CaseIterable {
		case large
		case regular
		case small
		case mini
		var controlSize: NSControl.ControlSize {
			switch self {
			case .large:
				if #available(macOS 11.0, *) {
					return .large
				} else {
					return .regular
				}
			case .regular: return .regular
			case .small: return .small
			case .mini: return .mini
			}
		}
	}

	/// Set the control size for the element
	func controlSize(_ controlSize: Control.ControlSize) -> Self {
		let sz = controlSize.controlSize
		self.control.controlSize = sz
		self.onControlSizeChange(sz)
		return self
	}
}

public extension Control {
	/// Set the enabled state for the control
	@discardableResult func isEnabled(_ isEnabled: Bool) -> Self {
		control.isEnabled = isEnabled
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	@discardableResult func font(_ font: NSFont?) -> Self {
		self.control.font = font
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	@discardableResult func font(_ font: AKBFont) -> Self {
		self.control.font = font.font
		return self
	}

	/// A dynamic font based on a font template
	@discardableResult func dynamicFont(_ font: AKBFont) -> Self {
		let dFont = DynamicFontService.shared.dynamicFont(for: font) ?? DynamicFontService.shared.add(font)
		return self.dynamicFont(dFont)
	}

	/// Set the font to be a dynamic font
	@discardableResult func dynamicFont(_ font: DynamicFont?) -> Self {
		guard let font = font else { return self }
		DynamicFontService.shared.register(self, font: font) { [weak self] newFont in
			guard let control = self?.control else { return }
			control.font = newFont
			control.needsLayout = true
			control.needsUpdateConstraints = true
			control.needsDisplay = true
			control.invalidateIntrinsicContentSize()

			control.layout()

			// If we're embedded in a collection view, make sure we invalidate the layout
			control.enclosingCollectionView()?.invalidateCollectionViewLayout()
		}
		self.hasDynamicFont = true
		return self
	}
}

// MARK: - Bindings

public extension Control {
	/// Binding for the control's font
	func bindFont(_ fontBinding: ValueBinder<NSFont?>) -> Self {
		fontBinding.register { [weak self] newValue in
			self?.control.font = newValue
		}
		self.fontBinder = fontBinding
		return self
	}
}
