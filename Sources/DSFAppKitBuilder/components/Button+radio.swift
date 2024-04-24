//
//  Button+radio.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
import Foundation

import DSFValueBinders

// MARK: - Radio grouping

/// A binder object for combining multiple button elements into a radio grouping
/// (ie. only a single selection at any one time)
///
/// let colorBinder = ValueBinder(RadioBinding())
public class RadioBinding {
	// The buttons in the radio grouping
	internal var radioButtons: [Button] = []

	// The currently selected index of the button within the group
	public private(set) var selectedIndex: Int = -1

	// The id for the currently selected item within the group
	public internal(set) var selectedID: UUID? {
		didSet {
			self.selectedIndex = self.radioButtons.firstIndex { $0.id == selectedID } ?? -1
		}
	}

	/// Default initializer
	public init() { }

	/// Activate the button at index
	/// - Parameter index: The index of the button to set the state to on
	public func activate(at index: Int) {
		(0 ..< radioButtons.count).forEach {
			radioButtons[$0].state($0 == index ? .on : .off)
		}
	}
}
