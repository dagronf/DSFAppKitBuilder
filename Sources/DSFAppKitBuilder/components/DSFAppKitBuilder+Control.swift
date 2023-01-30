//
//  DSFAppKitBuilder+Control.swift
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
}

// MARK: - Modifiers

public extension Control {
	/// Set the enabled state for the control
	func isEnabled(_ isEnabled: Bool) -> Self {
		control.isEnabled = isEnabled
		return self
	}

	/// Set the control size for the element
	func controlSize(_ controlSize: NSControl.ControlSize) -> Self {
		self.control.controlSize = controlSize
		self.onControlSizeChange(controlSize)
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	func font(_ font: NSFont?) -> Self {
		self.control.font = font
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	func font(_ font: AKBFont) -> Self {
		self.control.font = font.font
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
