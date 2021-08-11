//
//  DSFAppKitBuilder+Control.swift
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

import AppKit.NSControl

/// A DSL Element that is a control (ie. it is interactive in some way, like a button)
public class Control: Element {
	// Block the initializer so can't be created outside the package
	internal override init() {
		super.init()
	}


	deinit {
		isEnabledBinder?.deregister(self)
	}

	// Private
	private var isEnabledBinder: ValueBinder<Bool>?
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
		return self
	}
}

// MARK: - Bindings

public extension Control {
	/// Binding for isEnabled
	func bindIsEnabled(_ enabledBinding: ValueBinder<Bool>) -> Self {
		enabledBinding.register(self) { [weak self] newValue in
			self?.control.isEnabled = newValue
		}
		self.isEnabledBinder = enabledBinding
		return self
	}
}
