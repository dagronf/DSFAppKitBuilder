//
//  LabelStyle.swift
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

// MARK: - Label styling

public extension Label {
	enum Styling { }
}

public protocol LabelStyle {
	/// A method that applies label styles to the provided label
	func apply(_ labelElement: Label) -> Label
}

public extension Label {
	/// Apply a predefined Label style to the label
	@discardableResult func applyStyle(_ style: LabelStyle) -> Label {
		style.apply(self)
	}
}

public extension Label.Styling {
	/// Apply multiline wrapping for the label
	static let multiline = Multiline()
	static let truncatingTail = TruncatingTail()
	static let truncatingHead = TruncatingHead()
	static let truncatingMiddle = TruncatingMiddle()

	/// A multiline style for a label
	struct Multiline: DSFAppKitBuilder.LabelStyle {
		@discardableResult public func apply(_ labelElement: Label) -> Label {
			labelElement
				.horizontalCompressionResistancePriority(.defaultLow)
				.wraps(true)
				.truncatesLastVisibleLine(true)
		}
	}

	/// A single-line truncation style
	struct Truncating: DSFAppKitBuilder.LabelStyle {
		public init(_ lineBreakMode: NSLineBreakMode) {
			self.lineBreakMode = lineBreakMode
		}
		@discardableResult public func apply(_ labelElement: Label) -> Label {
			labelElement
				.truncatesLastVisibleLine(true)
				.lineBreakMode(self.lineBreakMode)
				.allowsDefaultTighteningForTruncation(true)
				.horizontalCompressionResistancePriority(.init(10))
		}
		private let lineBreakMode: NSLineBreakMode
	}

	/// A single-line tail truncation style
	struct TruncatingTail: DSFAppKitBuilder.LabelStyle {
		let truncator = Truncating(.byTruncatingTail)
		@discardableResult public func apply(_ labelElement: Label) -> Label {
			truncator.apply(labelElement)
		}
	}

	/// A single-line head truncation style
	struct TruncatingHead: DSFAppKitBuilder.LabelStyle {
		let truncator = Truncating(.byTruncatingHead)
		@discardableResult public func apply(_ labelElement: Label) -> Label {
			truncator.apply(labelElement)
		}
	}

	/// A single-line middle truncation style
	struct TruncatingMiddle: DSFAppKitBuilder.LabelStyle {
		let truncator = Truncating(.byTruncatingMiddle)
		@discardableResult public func apply(_ labelElement: Label) -> Label {
			truncator.apply(labelElement)
		}
	}
}
