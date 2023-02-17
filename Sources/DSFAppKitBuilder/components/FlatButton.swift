//
//  FlatButton.swift
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

import Foundation
import AppKit.NSButton
import DSFAppearanceManager

public class FlatButton: Button<CSFlatButton> {

	public struct Style {
		public let borderWidth: CGFloat
		public let color: NSColor
		public let borderColor: NSColor?
		public let textColor: NSColor?
		public let font: NSFont?

		static public let standard = Style()

		public init(
			borderWidth: CGFloat = 0.8,
			color: NSColor? = nil,
			borderColor: NSColor? = nil,
			textColor: NSColor? = nil,
			font: NSFont? = nil
		) {
			self.borderWidth = borderWidth
			self.color = color ?? DSFAppearanceCache.shared.accentColor
			self.borderColor = borderColor
			self.textColor = textColor
			self.font = font
		}
	}

	/// Create a flat button
	/// - Parameters:
	///   - title: The title for the button
	///   - type: The button type
	///   - style: The style to use when drawing the button
	///   - onChange: The block to call when the state of the button changes
	public init(
		title: String,
		type: NSButton.ButtonType = .momentaryLight,
		style: FlatButton.Style = .standard,
		_ onChange: Button<CSFlatButton>.ButtonAction? = nil
	) {
		super.init(title: title, type: type, bezelStyle: .roundRect, allowMixedState: false, onChange)

		self.button.buttonColor = style.color
		self.button.borderColor = style.borderColor
		self.button.borderWidth = style.borderWidth
		self.button.textColor = style.textColor
		if let font = style.font {
			self.button.font = font
		}

		self.receiveThemeNotifications = true
	}

	@objc public override func onThemeChange() {
		super.onThemeChange()
		self.button.needsDisplay = true
	}
}
