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
	/// The edge insets to apply to the field
	@objc var edgeInsets = NSEdgeInsets() {
		didSet {
			self.customCell.edgeInsets = edgeInsets
			self.needsLayout = true
			self.invalidateIntrinsicContentSize()
		}
	}

	class override var cellClass: AnyClass? {
		get { PaddedTextFieldCell.self }
		set {}
	}

	private var customCell: PaddedTextFieldCell { self.cell as! PaddedTextFieldCell }
}

// MARK: - Padded cell

extension PaddableTextField {
	class PaddedTextFieldCell: NSTextFieldCell {
		public var edgeInsets = NSEdgeInsets()

		override func cellSize(forBounds rect: NSRect) -> NSSize {
			var size = super.cellSize(forBounds: rect)
			size.width += (edgeInsets.left + edgeInsets.right)
			size.height += (edgeInsets.top + edgeInsets.bottom)
			return size
		}

		override func drawingRect(forBounds rect: NSRect) -> NSRect {
			var newRect = rect
			newRect.origin.x += edgeInsets.left
			newRect.size.width -= (edgeInsets.left + edgeInsets.right)
			newRect.origin.y += edgeInsets.top
			newRect.size.height -= (edgeInsets.top + edgeInsets.bottom)
			return super.drawingRect(forBounds: newRect)
		}
	}
}
