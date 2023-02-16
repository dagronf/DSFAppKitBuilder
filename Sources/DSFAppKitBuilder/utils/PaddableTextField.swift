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
			self.invalidateIntrinsicContentSize()
		}
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	var customCell: NSPaddedTextFieldCell { self.cell as! NSPaddedTextFieldCell }
}

extension PaddableTextField {

	class override var cellClass: AnyClass? {
		get { NSPaddedTextFieldCell.self }
		set {}
	}

	private func setup() {
		let new = NSPaddedTextFieldCell()
		let old = self.cell as! NSTextFieldCell

		// Copy the settings from the old cell into the new one

		new.font = old.font
		new.state = old.state

		new.stringValue = old.stringValue
		new.attributedStringValue = old.attributedStringValue

		new.textColor = old.textColor
		new.identifier = old.identifier
		new.alignment = old.alignment
		new.title = old.title
		new.image = old.image
		new.backgroundColor = old.backgroundColor
		new.backgroundStyle = old.backgroundStyle
		new.drawsBackground = old.drawsBackground
		new.bezelStyle = old.bezelStyle
		new.isBezeled = old.isBezeled
		new.isBordered = old.isBordered
		new.isEditable = old.isEditable
		new.isContinuous = old.isContinuous
		new.isEnabled = old.isEnabled
		new.isScrollable = old.isScrollable
		new.isHighlighted = old.isHighlighted

		new.wraps = old.wraps
		new.formatter = old.formatter
		new.tag = old.tag
		new.controlSize = old.controlSize

		self.cell = new
	}

	override var intrinsicContentSize: NSSize {
		var sz = super.intrinsicContentSize
		sz.width += (edgeInsets.left + edgeInsets.right)
		sz.height += (edgeInsets.top + edgeInsets.bottom)
		return sz
	}
}

extension PaddableTextField {
	class NSPaddedTextFieldCell: NSTextFieldCell {
		public var edgeInsets = NSEdgeInsets()
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
