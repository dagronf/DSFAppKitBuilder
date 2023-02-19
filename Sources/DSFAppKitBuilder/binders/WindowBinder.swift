//
//  WindowBinder.swift
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

import AppKit.NSView

/// Bind a window to a local variable
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

	/// Close the window if it is currently shown
	public func close() {
		self.window?.close()
	}

	deinit {
#if DEBUG
		Logger.Debug("WindowBinder [\(String(describing: self.window))] deinit")
#endif
		self.window = nil
	}
}
