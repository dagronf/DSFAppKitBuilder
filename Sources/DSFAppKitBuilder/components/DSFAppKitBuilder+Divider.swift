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

public class Divider: Element {

	public enum Direction {
		case horizontal
		case vertical
	}


	/// Create a divider
	/// - Parameters:
	///   - tag: (optional) The identifing tag
	///   - direction: The direction
	public init(tag: Int? = nil, direction: Direction) {
		if direction == .horizontal {
			separator = NSBox(frame: NSRect(x: 0, y: 0, width: 50, height: 5))
		}
		else {
			separator = NSBox(frame: NSRect(x: 0, y: 0, width: 5, height: 50))
		}
		super.init(tag: tag)
		separator.boxType = .separator
		if direction == .horizontal {
			_ = self.contentHugging(h: .defaultLow)
		}
		else {
			_ = self.contentHugging(v: .defaultLow)
		}
	}

	// Privates

	private let separator: NSBox
	public override var nsView: NSView { return separator }
}
