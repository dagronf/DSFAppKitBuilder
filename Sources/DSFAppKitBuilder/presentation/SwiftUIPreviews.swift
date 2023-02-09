//
//  SwiftUIPreviews.swift
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

// SwiftUI View generators for the DSFAppKitBuilder view types

import Foundation
import AppKit

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
public extension DSFAppKitBuilderViewHandler {
	/// Generate a SwiftUI preview encapsulating a DSFAppKitBuilderViewHandler object
	func SwiftUIPreview() -> DSFAppKitBuilderViewHandlerPreview {
		return DSFAppKitBuilderViewHandlerPreview(self)
	}
}

@available(macOS 10.15, *)
/// A SwiftUI Preview element wrapping a DSFAppKitBuilderView
public struct DSFAppKitBuilderViewHandlerPreview: NSViewRepresentable {
	let harness = DSFAppKitBuilderView()

	public init(_ builder: DSFAppKitBuilderViewHandler) {
		harness.element = builder.body
	}

	public func makeNSView(context: Context) -> DSFAppKitBuilderView {
		return harness
	}

	public func updateNSView(_ nsView: DSFAppKitBuilderView, context: Context) {

	}
}

@available(macOS 10.15, *)
extension DSFAppKitBuilderViewController {

	/// Generate a SwiftUI compatible view for this view controller
	public func SwiftUIPreview() -> DSFAppKitBuilderViewController.Preview {
		return DSFAppKitBuilderViewController.Preview(self)
	}

	public struct Preview: NSViewControllerRepresentable {
		let viewController: DSFAppKitBuilderViewController
		public init(_ viewController: DSFAppKitBuilderViewController) {
			self.viewController = viewController
		}
		public func makeNSViewController(context: Context) -> DSFAppKitBuilderViewController {
			return self.viewController
		}

		public func updateNSViewController(_ nsViewController: DSFAppKitBuilderViewController, context: Context) {

		}
	}
}

	/// A SwiftUI Preview element wrapping a DSFAppKitBuilder Element

@available(macOS 10.15, *)
extension Element {
	/// Generate a SwiftUI compatible view for this element
	public func SwiftUIPreview() -> Element.Preview { Self.Preview(element: self) }
	public struct Preview: NSViewRepresentable {
		let element: Element
		public func makeNSView(context: Context) -> NSView { return element.view() }
		public func updateNSView(_ nsView: NSView, context: Context) { }
	}
}

#endif
