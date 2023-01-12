//
//  DSFAppKitBuilder+Container.swift
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

/// A protocol for defining AppKitBuilder conformance for a class
public protocol DSFAppKitBuilderViewHandler: NSObjectProtocol {
	/// Return the root element to display within the Builder View
	var body: Element { get }
}

@available(macOS 10.15, *)
public extension DSFAppKitBuilderViewHandler {
	/// Generate a SwiftUI preview encapsulating a DSFAppKitBuilderViewHandler object
	func Preview() -> DSFAppKitBuilderViewHandlerPreview {
		return DSFAppKitBuilderViewHandlerPreview(self)
	}
}

/// Displays a DSFAppKitBuilder Element in a view
open class DSFAppKitBuilderView: NSView {

	/// Create an instance
	public init() {
		super.init(frame: .zero)
	}

	/// Create an instance
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	/// The builder to use when displaying the view
	///
	/// This object is not strongly held by the view. Thus, if you want to keep the builder around
	/// after the view has gone away you must hold onto the builder object elsewhere.
	///
	/// This allows a view to contain itself as a builder without having a reference count loop.
	public weak var builder: DSFAppKitBuilderViewHandler? {
		didSet {
			self.rootElement = self.builder?.body
		}
	}

	// The root element for the view
	private var rootElement: Element? {
		willSet {
			self.rootElement?.view().removeFromSuperview()
		}
		didSet {
			if let d = rootElement {
				self.addSubview(d.view())
				d.view().pinEdges(to: self)
			}
		}
	}
}
