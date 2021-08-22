//
//  ElementBinder.swift
//
//  Created by Darren Ford on 19/8/21
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

import AppKit.NSView

/// Bind an element to a local variable.
///
/// Useful if you need to access the element's view from somewhere else in the
/// view heirarchy, for example displaying a popover requires the element where
/// to point the 'tail' of the popover.
public class ElementBinder: CustomDebugStringConvertible {

	/// The element being bound.
	///
	/// This is weakly held so we don't potentially cause an ARC loop
	public internal(set) weak var element: Element?

	public var debugDescription: String {
		return "ElementBinder<\(String(describing: element))>"
	}

	/// Create an ElementBinder
	public init() { }

	deinit {
		self.element = nil
	}
}

// MARK: - Functions

public extension ElementBinder {
	/// Returns the element's view
	@inlinable var view: NSView? { return self.element?.view() }
	/// Returns the element's bounds
	@inlinable var frame: CGRect? { return self.view?.frame }
	/// Returns the element's frame
	@inlinable var bounds: CGRect? { return self.view?.bounds }

	/// Make the element the first responder for the window (ie. give it focus) if it can be focussed
	@inlinable func makeFirstResponder() {
		if let view = self.view, let window = view.window {
			window.makeFirstResponder(view)
		}
	}
}



public class WindowBinder: CustomDebugStringConvertible {

	/// The window being bound.
	///
	/// This is weakly held so we don't potentially cause an ARC loop
	public internal(set) weak var window: Window?

	public var debugDescription: String {
		return "WindowBinder<\(String(describing: window))>"
	}

	/// Create an ElementBinder
	public init() { }

	deinit {
		self.window = nil
	}
}


public class SheetBinder: CustomDebugStringConvertible {

	/// The window being bound.
	///
	/// This is weakly held so we don't potentially cause an ARC loop
	public internal(set) weak var sheet: Sheet?

	public var debugDescription: String {
		return "ShsetBinder<\(String(describing: sheet))>"
	}

	/// Create an ElementBinder
	public init() { }

	public func dismiss() {
		self.sheet?.dismiss()
	}

	deinit {
		self.sheet = nil
	}
}
