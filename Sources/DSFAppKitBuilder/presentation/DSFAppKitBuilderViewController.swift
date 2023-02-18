//
//  DSFAppKitBuilderViewController.swift
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

import AppKit

/// A view controller for controlling a DSFAppKitBuilder view
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

	public override func loadView() {
		self.reloadBody()
	}

	// Private

	// Keep a hold of the display body element, so that it doesn't deinit itself.
	// Internally most items are weakly held so it's the owners responsibility for
	// maintaining its lifecycle
	fileprivate var _displayElement: Element?
}

/// A view controller that displays the result of executing a builder function
internal class DSFAppKitBuilderAssignableViewController: DSFAppKitBuilderViewController {
	init(_ builder: @escaping () -> Element) {
		self._builder = builder
		super.init(nibName: nil, bundle: nil)
	}

	public override func loadView() {
		self.view = self.rootView
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var viewBody: Element {
		self._builder()
	}

	internal func reset() {
		self._displayElement = nil
		self.rootView.element = Nothing()
	}

	private let _builder: () -> Element
	internal let rootView = DSFAppKitBuilderView()
}
