//
//  DSFAppKitBuilder+AutoLayout.swift
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

import AppKit

public extension Element {
	// MARK: - Autolayout

	func priority(
		orientation: NSLayoutConstraint.Orientation,
		hugging: NSLayoutConstraint.Priority? = nil,
		compressionResistance resistance: NSLayoutConstraint.Priority? = nil
	) -> Self {
		if let hugging = hugging {
			self.nsView.setContentHuggingPriority(hugging, for: orientation)
		}
		if let resistance = resistance {
			self.nsView.setContentCompressionResistancePriority(resistance, for: orientation)
		}
		return self
	}

	@inlinable func horizontalPriorities(hugging: Float? = nil, compressionResistance resistance: Float? = nil) -> Self {
		return self.priority(
			orientation: .horizontal,
			hugging: hugging != nil ? NSLayoutConstraint.Priority(hugging!) : nil,
			compressionResistance: resistance != nil ? NSLayoutConstraint.Priority(resistance!) : nil
		)
	}

	@inlinable func horizontalPriorities(hugging: NSLayoutConstraint.Priority? = nil, compressionResistance resistance: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.priority(
			orientation: .horizontal, hugging: hugging, compressionResistance: resistance
		)
	}

	@inlinable func verticalPriorities(hugging: Float? = nil, compressionResistance resistance: Float? = nil) -> Self {
		return self.priority(
			orientation: .vertical,
			hugging: hugging != nil ? NSLayoutConstraint.Priority(hugging!) : nil,
			compressionResistance: resistance != nil ? NSLayoutConstraint.Priority(resistance!) : nil
		)
	}

	@inlinable func verticalPriorities(hugging: NSLayoutConstraint.Priority? = nil, compressionResistance resistance: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.priority(
			orientation: .vertical, hugging: hugging, compressionResistance: resistance
		)
	}
}
