//
//  ButtonStyle.swift
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
import AppKit

// MARK: - Button styling

public extension Button {
	enum Styling { }
}

/// A style protocol for Button
public protocol ButtonStyle {
	/// A method that applies button styles to the provided button
	func apply(_ buttonElement: Button) -> Button
}

public extension Button {
	/// Apply a predefined Button style to the button
	@discardableResult func applyStyle(_ style: ButtonStyle) -> Button {
		style.apply(self)
	}
}

// MARK: - Predefined button styles

public extension Button.Styling {
	/// Remove any bezel/border from the button
	static let noBorder = Unbezeled()

	/// A multiline style for a label
	struct Unbezeled: DSFAppKitBuilder.ButtonStyle {
		@discardableResult public func apply(_  buttonElement: Button) -> Button {
			buttonElement
				.isBordered(false)
		}
	}
}
