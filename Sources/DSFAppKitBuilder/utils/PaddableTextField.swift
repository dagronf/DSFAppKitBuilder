//
//  PaddableTextField.swift
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

	override var intrinsicContentSize: NSSize {
		var sz = super.intrinsicContentSize
		sz.width += (edgeInsets.left + edgeInsets.right)
		sz.height += (edgeInsets.top + edgeInsets.bottom)
		return sz
	}
}

extension PaddableTextField {
	// Custom paddable cell
	private class PaddableTextFieldCell: NSTextFieldCell {
		var edgeInsets = NSEdgeInsets()

		override func titleRect(forBounds rect: NSRect) -> NSRect {
			var titleFrame = super.titleRect(forBounds: rect)
			titleFrame.origin.x += edgeInsets.left
			titleFrame.size.width -= (edgeInsets.left + edgeInsets.right)
			titleFrame.origin.y += edgeInsets.top
			titleFrame.size.height -= (edgeInsets.top + edgeInsets.bottom)
			return titleFrame
		}

		override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
			var newRect = rect
			newRect.origin.x += edgeInsets.left
			newRect.size.width -= (edgeInsets.left + edgeInsets.right)
			newRect.origin.y += edgeInsets.top
			newRect.size.height -= (edgeInsets.top + edgeInsets.bottom)
			super.edit(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, event: event)
		}

		override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
			var newRect = rect
			newRect.origin.x += edgeInsets.left
			newRect.size.width -= (edgeInsets.left + edgeInsets.right)
			newRect.origin.y += edgeInsets.top
			newRect.size.height -= (edgeInsets.top + edgeInsets.bottom)
			super.select(withFrame: newRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
		}

		override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
			let titleRect = self.titleRect(forBounds: cellFrame)
			self.attributedStringValue.draw(in: titleRect)
		}
	}
}
