//
//  CSFlatButton.swift
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

import AppKit.NSButton
import DSFAppearanceManager
import Foundation

// A custom button style

@IBDesignable
public class CSFlatButton: NSButton {
	/// The width of the border
	@IBInspectable public var borderWidth: CGFloat = 0.8
	/// The button's color (uses the accent color by default)
	@IBInspectable public var buttonColor: NSColor = DSFAppearanceCache.shared.accentColor
	/// The border color. If nil, generates a default border color
	@IBInspectable public var borderColor: NSColor? = nil
	/// The button's text color. If nil, uses a contrasting color to the button color
	@IBInspectable public var textColor: NSColor? = nil

	override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}
}

extension CSFlatButton {
	private func setup() {
		self.wantsLayer = true
		self.bezelStyle = .roundRect
		self.isBordered = false
	}
}

public extension CSFlatButton {
	override func drawFocusRingMask() {
		let corner = self.frame.height / 2.5
		let rectanglePath = NSBezierPath(roundedRect: self.bounds, xRadius: corner, yRadius: corner)
		rectanglePath.fill()
	}

	override var intrinsicContentSize: NSSize {
		var sz = super.intrinsicContentSize
		sz.width += 10
		sz.height += {
			switch self.controlSize {
			case .large: return 4
			case .regular: return 2
			case .small: return 0
			case .mini: return -1
			default: return 2
			}
		}()
		return sz
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		self.usingEffectiveAppearance {
			let newBounds = self.bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)

			let corner = self.frame.height / 2.5
			let rectanglePath = NSBezierPath(roundedRect: newBounds, xRadius: corner, yRadius: corner)

			do {
				// Draw the default color
				self.buttonColor.setFill()
				rectanglePath.fill()
			}

			do {
				// Use the specified border color
				if let borderColor = self.borderColor {
					rectanglePath.lineWidth = self.borderWidth
					borderColor.setStroke()
					rectanglePath.stroke()
				}
				else {
					// Use a created border color
					self.buttonColor.setStroke()
					rectanglePath.lineWidth = self.borderWidth
					rectanglePath.stroke()

					if DSFAppearanceManager.IncreaseContrast {
						NSColor.textColor.setStroke() // withAlphaComponent(0.5).setStroke()
					}
					else {
						NSColor.textColor.withAlphaComponent(0.5).setStroke()
					}
					rectanglePath.lineWidth = self.borderWidth
					rectanglePath.stroke()
				}
			}

			let textRect = newBounds // NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
			let textTextContent = self.title
			let textStyle = NSMutableParagraphStyle()
			textStyle.alignment = .center

			let tc = self.textColor ?? self.buttonColor.flatContrastColor()

			var textFontAttributes: [NSAttributedString.Key: Any] = [
				.foregroundColor: tc,
				.paragraphStyle: textStyle,
			]
			if let font = super.font {
				textFontAttributes[.font] = font
			}

			let textTextHeight: CGFloat = textTextContent.boundingRect(with: NSSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes).height
			let textTextRect: NSRect = NSRect(x: 0, y: -2.5 + ((self.bounds.height - textTextHeight) / 2), width: textRect.width, height: textTextHeight)
			NSGraphicsContext.saveGraphicsState()
			textTextContent.draw(in: textTextRect.offsetBy(dx: 0, dy: 2.5), withAttributes: textFontAttributes)
			NSGraphicsContext.restoreGraphicsState()

			if self.isHighlighted {
				if DSFAppearanceManager.IsDark {
					NSColor.textColor.withAlphaComponent(0.4).setFill()
				}
				else {
					NSColor.textColor.withAlphaComponent(0.1).setFill()
				}
				rectanglePath.fill()
			}
		}
	}
}
