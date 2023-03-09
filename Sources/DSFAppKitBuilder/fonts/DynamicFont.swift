//
//  DynamicFont.swift
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

/// A Dynamic font
public class DynamicFont {
	/// The font you use for body text.
	public static let system = DynamicFont(.system)
	/// A small system font
	public static let systemSmall = DynamicFont(.systemSmall)
	/// System font at label size
	public static let label = DynamicFont(.label)
	/// The font you use for body text.
	public static let body = DynamicFont(.body)
	/// The font you use for large titles.
	public static let largeTitle = DynamicFont(.largeTitle)
	/// The font you use for first-level hierarchical headings.
	public static let title1 = DynamicFont(.title1)
	/// The font you use for second-level hierarchical headings.
	public static let title2 = DynamicFont(.title2)
	/// The font you use for third-level hierarchical headings.
	public static let title3 = DynamicFont(.title3)
	/// The font you use for standard captions.
	public static let caption1 = DynamicFont(.caption1)
	/// The font you use for alternate captions.
	public static let caption2 = DynamicFont(.caption2)
	/// The font you use for headings.
	public static let headline = DynamicFont(.headline)
	/// The font you use for subheadings.
	public static let subheadline = DynamicFont(.subheadline)
	/// The font you use in footnotes.
	public static let footnote = DynamicFont(.footnote)
	/// The font to use for monospaced text
	public static let monospaced = DynamicFont(.monospaced)
	/// A font with monospaced digits
	public static let monospacedDigit = DynamicFont(.monospacedDigit)

	internal static let DefaultFonts: [DynamicFont] = [
		.system, .systemSmall, .label, .body, .largeTitle,
		.title1, .title2, .title3, .headline, .subheadline,
		.footnote, .monospaced, monospacedDigit, caption1, caption2
	]

	internal init(_ font: AKBFont) {
		self.templateFont = font
		self.defaultSize = font.font.pointSize
		self.fontDescriptor = font.font.fontDescriptor
		self.currentFont = font.font
	}

	/// Scale the font by the fraction amount
	internal func scale(by fraction: Double) {
		let newSize = (self.defaultSize * fraction).rounded()
		if let mf = NSFont(descriptor: self.fontDescriptor, size: newSize) {
			self.currentFont = mf
			self.currentScale = fraction
		}
	}

	internal let templateFont: AKBFont
	internal var currentScale: Double = 1.0
	internal var currentFont: NSFont

	private let defaultSize: Double
	private let fontDescriptor: NSFontDescriptor
}

