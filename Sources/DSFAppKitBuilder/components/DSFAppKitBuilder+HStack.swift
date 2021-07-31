//
//  DSFAppKitBuilder+HStack.swift
//
//  Created by Darren Ford on 30/7/21
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


import AppKit.NSStackView

/// A horizontal NSStackView wrapper
public class HStack: Stack {

	/// Create a horizontal stack
	/// - Parameters:
	///   - spacing: The minimum spacing, in points, between adjacent views in the stack view
	///   - alignment: The view alignment within the stack view
	///   - distribution: The spacing and sizing distribution of stacked views along the primary axis. Defaults to GravityAreas.
	///   - builder: The builder for generating the stack's content
	public convenience init(
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute = .centerY,
		distribution: NSStackView.Distribution? = nil,
		@ElementBuilder builder: () -> [Element]
	) {
		self.init(
			orientation: .horizontal,
			spacing: spacing,
			alignment: alignment,
			distribution: distribution,
			content: builder())
	}
}
