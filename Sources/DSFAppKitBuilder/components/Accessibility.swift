//
//  Accessibility.swift
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

import Foundation
import AppKit.NSAccessibility

// Accessibility conveniences for elements

public extension Element {
	/// Element Accessibility traits
	enum AccessibilityTraits {
		/// Sets the title of the accessibility element.
		case title(String?)
		/// Sets a short description of the accessibility element.
		case label(String?)
		/// Sets the help text for the accessibility element.
		case help(String?)
		/// Sets the type of interface element that the accessibility element represents.
		case role(NSAccessibility.Role)
		/// Set that the element is an accessibility group (useful for Stacks, Groups etc.
		case group(String?)
	}

	/// Set accessibility attributes to the element
	func accessibility(_ types: [AccessibilityTraits]) -> Self {
		let view = self.view()
		types.forEach { type in
			switch type {
			case .title(let title):
				view.setAccessibilityTitle(title)
			case .label(let label):
				view.setAccessibilityLabel(label)
			case .help(let helpLabel):
				view.setAccessibilityHelp(helpLabel)
			case .role(let role):
				view.setAccessibilityRole(role)
			case .group(let title):
				view.setAccessibilityElement(true)
				view.setAccessibilityRole(.group)
				view.setAccessibilityTitle(title)
			}
		}
		return self
	}
}
