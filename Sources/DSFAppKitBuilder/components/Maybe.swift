//
//  Maybe.swift
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

import Foundation
import AppKit

/// A Maybe element which optionally adds an element to the build
///
/// Mostly useful for HStack/VStack builds
public class Maybe: Element {

	/// An element IF a condition block returns as true
	public init(_ condition: @autoclosure () -> Bool, _ element: () -> Element) {
		if condition() {
			self.underlyingView = element().view()
		}
		else {
			self.underlyingView = NothingView()
		}
	}

	/// An element IF a condition block returns as true
	public init(_ condition: @autoclosure () -> Bool, _ element: Element) {
		if condition() {
			self.underlyingView = element.view()
		}
		else {
			self.underlyingView = NothingView()
		}
	}

	/// If the element is non-nil, adds the element to the build, otherwise it is ignored
	public init(_ element: Element?) {
		self.underlyingView = element?.view() ?? NothingView()
	}

	public override func view() -> NSView { self.underlyingView }
	private let underlyingView: NSView
}
