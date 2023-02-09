//
//  PaddableTextField.swift
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

import AppKit
import Foundation

// A textfield with configurable edge insets
class PaddableTextField: NSTextField {
	/// Set the edge inset padding for the text field
	var edgeInsets: NSEdgeInsets {
		get {
			self.customCell.edgeInsets
		}
		set {
			self.customCell.edgeInsets = newValue
			self.needsDisplay = true
			self.needsLayout = true
		}
	}

	/// Set equal padding on all edges of the text field
	var padding: CGFloat {
		get { 0 }
		set { self.customCell.edgeInsets = NSEdgeInsets(edgeInset: newValue) }
	}

	// Private

	private var customCell: PaddableTextFieldCell {
		self.cell as! PaddableTextFieldCell
	}

	override class var cellClass: AnyClass? {
		get { PaddableTextFieldCell.self }
		set {}
	}
}

private class PaddableTextFieldCell: NSTextFieldCell {
	var edgeInsets = NSEdgeInsets()

	override func cellSize(forBounds rect: NSRect) -> NSSize {
		var size = super.cellSize(forBounds: rect)
		size.height += (self.edgeInsets.top + self.edgeInsets.bottom)
		return size
	}

	override func titleRect(forBounds rect: NSRect) -> NSRect {
		return rect.insetBy(dx: self.edgeInsets.left, dy: self.edgeInsets.top)
	}

	override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
		let insetRect = rect.insetBy(dx: self.edgeInsets.left, dy: self.edgeInsets.top)
		super.edit(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, event: event)
	}

	override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
		let insetRect = rect.insetBy(dx: self.edgeInsets.left, dy: self.edgeInsets.top)
		super.select(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
	}

	override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
		let insetRect = cellFrame.insetBy(dx: self.edgeInsets.left, dy: self.edgeInsets.top)
		super.drawInterior(withFrame: insetRect, in: controlView)
	}
}
