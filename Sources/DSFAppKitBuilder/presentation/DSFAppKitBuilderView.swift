//
//  DSFAppKitBuilderView.swift
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

/// A simple NSView for displaying a DSFAppKitBuilder Element
open class DSFAppKitBuilderView: NSView {
	/// The element to display in the view
	///
	/// Must be set on the main thread
	public var element: Element? {
		get { _element }
		set {
			assert(Thread.isMainThread)
			self.setRootElement(newValue)
		}
	}

	/// Create a empty view
	///
	/// Assign to `element` to display
	public init() {
		self._element = nil
		super.init(frame: .zero)
		self.configure()
	}

	/// Create and evaluate the builder block to determine the content
	public init(_ builder: () -> Element) {
		self._element = builder()
		super.init(frame: .zero)
		self.configure()
	}

	/// Create by evaluating a builder view handler
	public init(_ handler: DSFAppKitBuilderViewHandler) {
		self._element = handler.body
		super.init(frame: .zero)
		self.configure()
	}

	/// Create and display an element
	public init(element: Element) {
		self._element = element
		super.init(frame: .zero)
		self.configure()
	}

	/// Create via interface builder
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configure()
	}

	/// Set the content of the view using a view handler.
	///
	/// This object is not strongly held by the view. Thus, if you want to keep the handler around
	/// after the view has gone away you must hold onto the builder object elsewhere.
	///
	/// This allows a view to contain itself as a handler without having a reference count loop.
	public func setHandler(_ handler: DSFAppKitBuilderViewHandler) {
		self.element = handler.body
	}

	deinit {
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("DSFAppKitBuilderView deinit (element: \(element?.id.uuidString ?? "<nil>")")
		}
	}

	// private
	private var _element: Element? = nil
}

private extension DSFAppKitBuilderView {
	private func configure() {
		assert(Thread.isMainThread)

		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true

		self.setRootElement(self._element)
	}

	private func setRootElement(_ element: Element?) {
		assert(Thread.isMainThread)

		// If there was an element being displayed, remove it.
		if let rootView = _element?.view() {
			rootView.removeFromSuperview()
		}
		_element = element

		// Install the element's view
		if let rootView = element?.view() {
			self.addSubview(rootView)
			rootView.pinEdges(to: self)

			self.needsLayout = true
			self.needsDisplay = true
		}
	}
}
