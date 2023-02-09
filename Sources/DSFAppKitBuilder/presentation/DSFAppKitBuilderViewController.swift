//
//  DSFAppKitBuilderViewController.swift
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

import AppKit

/// A View Controller for controlling a DSFAppKitBuilder view
open class DSFAppKitBuilderViewController: NSViewController {

	/// The body for the view. Must be overridden in derived classes to display content
	open var viewBody: Element {
		Swift.print("WARNING: \(Self.self) has not defined builder view content")
		return EmptyView()
	}

	/// Rebuild the view from the viewBody
	public func reloadBody() {
		self._displayElement = self.viewBody
		self.view = self._displayElement?.view() ?? NSView()
	}

	// Private

	// Keep a hold of the display body element, so that it doesn't deinit itself.
	// Internally most items are weakly held so it's the owners responsibility for
	// maintaining its lifecycle
	private var _displayElement: Element?
}

extension DSFAppKitBuilderViewController {
	public override func loadView() {
		self.reloadBody()
	}
}
