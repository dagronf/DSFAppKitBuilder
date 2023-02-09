//
//  AutoLayout.swift
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
//

import AppKit

// MARK: - Autolayout helpers

public extension Element {

	/// Set the horizontal hugging and compression resistance properties for an element
	@inlinable func horizontalPriorities(hugging: Float? = nil, compressionResistance resistance: Float? = nil) -> Self {
		return self.priority(
			orientation: .horizontal,
			hugging: hugging != nil ? NSLayoutConstraint.Priority(hugging!) : nil,
			compressionResistance: resistance != nil ? NSLayoutConstraint.Priority(resistance!) : nil
		)
	}

	/// Set the horizontal hugging and compression resistance properties for an element
	@inlinable func horizontalPriorities(hugging: NSLayoutConstraint.Priority? = nil, compressionResistance resistance: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.priority(
			orientation: .horizontal,
			hugging: hugging,
			compressionResistance: resistance
		)
	}

	/// Set the vertical hugging and compression resistance properties for an element
	@inlinable func verticalPriorities(hugging: Float? = nil, compressionResistance resistance: Float? = nil) -> Self {
		return self.priority(
			orientation: .vertical,
			hugging: hugging != nil ? NSLayoutConstraint.Priority(hugging!) : nil,
			compressionResistance: resistance != nil ? NSLayoutConstraint.Priority(resistance!) : nil
		)
	}

	/// Set the vertical hugging and compression resistance properties for an element
	@inlinable func verticalPriorities(hugging: NSLayoutConstraint.Priority? = nil, compressionResistance resistance: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.priority(
			orientation: .vertical,
			hugging: hugging,
			compressionResistance: resistance
		)
	}
}

public extension Element {
	/// Set the hugging and compression resistance properties for an element
	func priority(
		orientation: NSLayoutConstraint.Orientation,
		hugging: NSLayoutConstraint.Priority? = nil,
		compressionResistance resistance: NSLayoutConstraint.Priority? = nil
	) -> Self {
		if let hugging = hugging {
			self.view().setContentHuggingPriority(hugging, for: orientation)
		}
		if let resistance = resistance {
			self.view().setContentCompressionResistancePriority(resistance, for: orientation)
		}
		return self
	}
}

public extension Element {
	/// Sets the priority with which a view resists being made smaller than its intrinsic size.
	///
	/// See: [documentation](https://developer.apple.com/documentation/appkit/nsview/1524974-setcontentcompressionresistancep)
	@inlinable func horizontalCompressionResistancePriority(_ priority: NSLayoutConstraint.Priority) -> Self {
		self.view().setContentCompressionResistancePriority(priority, for: .horizontal)
		return self
	}
	/// Sets the priority with which a view resists being made smaller than its intrinsic size.
	///
	/// See: [documentation](https://developer.apple.com/documentation/appkit/nsview/1524974-setcontentcompressionresistancep)
	@inlinable func verticalCompressionResistancePriority(_ priority: NSLayoutConstraint.Priority) -> Self {
		self.view().setContentCompressionResistancePriority(priority, for: .vertical)
		return self
	}

	/// Sets the priority with which a view resists being made larger than its intrinsic size.
	///
	/// See: [documentation](https://developer.apple.com/documentation/appkit/nsview/1526937-setcontenthuggingpriority)
	@inlinable func horizontalHuggingPriority(_ priority: NSLayoutConstraint.Priority) -> Self {
		self.view().setContentHuggingPriority(priority, for: .horizontal)
		return self
	}

	@inlinable func horizontalHuggingPriority(_ priority: Float) -> Self {
		self.view().setContentHuggingPriority(NSLayoutConstraint.Priority(priority), for: .horizontal)
		return self
	}

	/// Sets the priority with which a view resists being made larger than its intrinsic size.
	///
	/// See: [documentation](https://developer.apple.com/documentation/appkit/nsview/1526937-setcontenthuggingpriority)
	@inlinable func verticalHuggingPriority(_ priority: NSLayoutConstraint.Priority) -> Self {
		self.view().setContentHuggingPriority(priority, for: .vertical)
		return self
	}
}
