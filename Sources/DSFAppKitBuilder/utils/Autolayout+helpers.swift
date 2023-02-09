//
//  Autolayout+helpers.swift
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

extension NSView {
	// Pin 'self' within 'other' view
	internal func pinEdges(to other: NSView, edgeInset: CGFloat = 0, animate: Bool = false) {
		self.pinEdges(to: other, edgeInsets: NSEdgeInsets(edgeInset: edgeInset), animate: animate)
	}

	// Pin 'self' within 'other' view
	internal func pinEdges(to other: NSView, edgeInsets: NSEdgeInsets, animate: Bool = false) {
		let target = animate ? animator() : self
		target.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: edgeInsets.left).isActive = true
		target.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -edgeInsets.right).isActive = true
		target.topAnchor.constraint(equalTo: other.topAnchor, constant: edgeInsets.top).isActive = true
		target.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -edgeInsets.bottom).isActive = true
	}

	// Pin 'self' within 'other' view
	@discardableResult
	internal func center(in other: NSView, edgeInset: CGFloat = 0) -> [NSLayoutConstraint] {
		return self.center(in: other, edgeInsets: NSEdgeInsets(edgeInset: edgeInset))
	}

	// Center 'self' within 'other' view
	@discardableResult
	internal func center(in other: NSView, edgeInsets: NSEdgeInsets) -> [NSLayoutConstraint] {
		let constraints = [
			NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: other, attribute: .leading, multiplier: 1, constant: edgeInsets.left),
			NSLayoutConstraint(item: self, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: other, attribute: .top, multiplier: 1, constant: edgeInsets.top),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: other, attribute: .trailing, multiplier: 1, constant: edgeInsets.right),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: other, attribute: .bottom, multiplier: 1, constant: edgeInsets.bottom),

			NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: other, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: other, attribute: .centerY, multiplier: 1, constant: 0)
		]

		other.addConstraints(constraints)
		return constraints
	}

}

extension NSLayoutConstraint.Priority {
	@inlinable static func ValueOrNil(_ value: Float?) -> NSLayoutConstraint.Priority? {
		guard let v = value else { return nil }
		return NSLayoutConstraint.Priority(rawValue: v)
	}
}
