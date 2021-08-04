//
//  DSFAppKitBuilder+Stack.swift
//
//  Created by Darren Ford on 27/7/21
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

/// A base class for stack element.
public class Stack: Element {
	internal init(
		orientation: NSUserInterfaceLayoutOrientation,
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute,
		distribution: NSStackView.Distribution? = nil,
		content: [Element]
	) {
		self.content = content
		super.init()
		self.stack.spacing = spacing
		self.stack.orientation = orientation
		self.stack.alignment = alignment

		if let d = distribution {
			_ = self.distribution(d)
		}

		content.forEach {
			stack.addArrangedSubview($0.nsView)
			$0.addedToParentView(parent: stack)
		}

		self.stack.needsLayout = true
		self.stack.needsUpdateConstraints = true
	}

	// Private
	override var nsView: NSView { return self.stack }
	private let stack = NSStackView()
	private let content: [Element]
}

// MARK: - Modifiers

public extension Stack {
	/// The minimum spacing, in points, between adjacent views in the stack view.
	func spacing(_ spacing: CGFloat) -> Self {
		self.stack.spacing = spacing
		return self
	}

	/// The spacing and sizing distribution of stacked views along the primary axis. Defaults to GravityAreas.
	func distribution(_ dist: NSStackView.Distribution) -> Self {
		self.stack.distribution = dist
		return self
	}

	/// The view alignment within the stack view.
	func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
		self.stack.alignment = alignment
		return self
	}

	/// Set the hugging priorites for the stack
	func hugging(h: NSLayoutConstraint.Priority? = nil, v: NSLayoutConstraint.Priority? = nil) -> Self {
		if let h = h {
			self.nsView.setContentHuggingPriority(h, for: .horizontal)
		}
		if let v = v {
			self.nsView.setContentHuggingPriority(v, for: .vertical)
		}
		return self
	}

	/// Set the hugging priorites for the stack
	func hugging(h: Float? = nil, v: Float? = nil) -> Self {
		if let h = h {
			self.nsView.setContentHuggingPriority(NSLayoutConstraint.Priority(h), for: .horizontal)
		}
		if let v = v {
			self.nsView.setContentHuggingPriority(NSLayoutConstraint.Priority(v), for: .vertical)
		}
		return self
	}

	// MARK: - Edge insets

	/// The geometric padding, in points, inside the stack view, surrounding its views.
	func edgeInsets(_ edgeInsets: NSEdgeInsets) -> Self {
		self.stack.edgeInsets = edgeInsets
		return self
	}

	/// The geometric padding, in points, inside the stack view, surrounding its views.
	@inlinable func edgeInsets(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
		return self.edgeInsets(NSEdgeInsets(top: top, left: left, bottom: bottom, right: right))
	}

	/// The geometric padding, in points, inside the stack view, surrounding its views.
	func edgeInsets(_ value: CGFloat) -> Self {
		return self.edgeInsets(NSEdgeInsets(top: value, left: value, bottom: value, right: value))
	}
}

// MARK: - Horizontal Stack

/// A convenience class for a horizontal NSStackView wrapper
///
/// Usage:
///
/// ```swift
/// HStack(distribution: .fillEqually) {
///    Label("Name").alignment(.right).horizontalPriorities(hugging: 10)
///    TextField().alignment(.left).horizontalPriorities(hugging: 10)
/// }
/// ```
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

// MARK: - Vertical Stack

/// A convenience class for a vertical NSStackView wrapper
///
/// Usage:
///
/// ```swift
/// VStack(distribution: .fillEqually) {
///    Label("Name").alignment(.right).horizontalPriorities(hugging: 10)
///    TextField().alignment(.left).horizontalPriorities(hugging: 10)
/// }
/// ```
public class VStack: Stack {

	/// Create a vertical stack
	/// - Parameters:
	///   - spacing: The minimum spacing, in points, between adjacent views in the stack view
	///   - alignment: The view alignment within the stack view
	///   - distribution: The spacing and sizing distribution of stacked views along the primary axis. Defaults to GravityAreas.
	///   - builder: The builder for generating the stack's content
	public convenience init(
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute = .centerX,
		distribution: NSStackView.Distribution? = nil,
		@ElementBuilder builder: () -> [Element]
	) {
		self.init(
			orientation: .vertical,
			spacing: spacing,
			alignment: alignment,
			distribution: distribution,
			content: builder())
	}
}

