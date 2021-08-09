//
//  DSFAppKitBuilder+Divider.swift
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

import AppKit.NSBox

/// A divider element
public class Divider: Element {

	/// The direction for the divider
	public enum Orientation {
		/// Horizontal orientation
		case horizontal
		/// Vertical orientation
		case vertical
	}

	/// Create a divider
	/// - Parameters:
	///   - orientation: The dividers orientation
	public init(orientation: Orientation) {
		if orientation == .horizontal {
			separator = NSBox(frame: NSRect(x: 0, y: 0, width: 50, height: 5))
		}
		else {
			separator = NSBox(frame: NSRect(x: 0, y: 0, width: 5, height: 50))
		}
		super.init()
		separator.boxType = .separator
		if orientation == .horizontal {
			_ = self.horizontalPriorities(hugging: .defaultLow)
		}
		else {
			_ = self.verticalPriorities(hugging: .defaultLow)
		}
	}

	// Privates

	private let separator: NSBox
	override public var nsView: NSView { return separator }
}

/// A convenience class for a vertical divider element
public class VDivider: Divider {
	/// Create a vertical divider
	public init() {
		super.init(orientation: .vertical)
	}
}

/// A convenience class for a horizontal divider element
public class HDivider: Divider {
	/// Create a horizontal divider
	public init() {
		super.init(orientation: .horizontal)
	}
}
