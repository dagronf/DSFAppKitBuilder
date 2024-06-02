//
//  Element+Size.swift
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
import DSFValueBinders

// MARK: - Dimensions

public extension Element {
	/// Set a size for the element
	/// - Parameters:
	///   - width: The width for the element
	///   - height: The height for the element
	///   - priority: The priority to apply to both the width and the height
	/// - Returns: Self
	@discardableResult
	func size(width: Double, height: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self
			.width(width, priority: priority)
			.height(height, priority: priority)
	}
}

// MARK: Width setting

public extension Element {
	// All the width constraints for the element
	private var allWidthConstraints: [NSLayoutConstraint] {
		self.view().constraints.filter({ $0.identifier == "forcedWidth" })
	}

	/// Set the width of the element
	///
	/// If the value is nil, no constraint is applied
	@discardableResult
	func width(
		_ value: Double?,
		relation: NSLayoutConstraint.Relation = .equal,
		priority: NSLayoutConstraint.Priority? = nil
	) -> Self {
		guard let value = value else { return self }
		with(self.view()) { view in
			// Remove any forced width constraints firest
			allWidthConstraints.forEach { view.removeConstraint($0) }

			// Create and attach a new width constraint
			let c = NSLayoutConstraint(
				item: view, attribute: .width,
				relatedBy: relation,
				toItem: nil, attribute: .notAnAttribute,
				multiplier: 1, constant: CGFloat(value)
			)
			if let p = priority { c.priority = p }
			c.identifier = "forcedWidth"
			view.addConstraint(c)
		}
		return self
	}

	/// Set the width of the element
	///
	/// If the value is nil, no constraint is applied
	@discardableResult
	func width(_ value: Double?, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.width(value, relation: .equal, priority: priority)
	}

	/// Set the minimum width of the element
	@discardableResult
	func minWidth(_ value: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.width(value, relation: .greaterThanOrEqual, priority: priority)
	}

	/// Set the maximum width of the element
	@discardableResult
	func maxWidth(_ value: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.width(value, relation: .lessThanOrEqual, priority: priority)
	}
}

// MARK: Height setting

public extension Element {
	// Get all constraints marked as our height constraints
	private var allHeightConstraints: [NSLayoutConstraint] {
		self.view().constraints.filter({ $0.identifier == "forcedHeight" })
	}

	/// Set the height of the element
	///
	/// If the value is nil, no constraint is applied
	@discardableResult
	func height(_ value: Double?, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		guard let value = value else { return self }
		with(self.view()) { view in
			// Removed any forced height constraints
			allHeightConstraints.forEach { view.removeConstraint($0) }

			// Create and attach a new height constraint
			let c = NSLayoutConstraint(
				item: view, attribute: .height,
				relatedBy: relation,
				toItem: nil, attribute: .notAnAttribute,
				multiplier: 1, constant: CGFloat(value)
			)
			if let p = priority { c.priority = p }
			c.identifier = "forcedHeight"
			view.addConstraint(c)
		}
		return self
	}

	/// Set the height of the element
	///
	/// If the value is nil, no constraint is applied
	@discardableResult
	func height(_ value: Double?, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.height(value, relation: .equal, priority: priority)
	}

	/// Set the minimum height of the element
	@discardableResult
	func minHeight(_ value: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.height(value, relation: .greaterThanOrEqual, priority: priority)
	}

	/// Set the maximum height of the element
	@discardableResult
	func maxHeight(_ value: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.height(value, relation: .lessThanOrEqual, priority: priority)
	}
}

// MARK: Binding

public extension Element {
	/// Bind the element's width
	/// - Parameters:
	///   - widthBinder: The width binder
	///   - priority: The autolayout priority
	/// - Returns: self
	@discardableResult func bindWidth(
		_ widthBinder: ValueBinder<Double>,
		priority: NSLayoutConstraint.Priority? = nil
	) -> Self {
		guard allWidthConstraints.isEmpty else {
			assert(false, "Attempting to bind width constraint to an element with a fixed width already assigned")
			return self
		}

		let view = self.view()

		let c = NSLayoutConstraint(
			item: view, attribute: .width,
			relatedBy: .equal,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1, constant: widthBinder.wrappedValue
		)
		c.identifier = "forcedWidth"
		if let p = priority { c.priority = p }
		view.addConstraint(c)

		widthBinder.register(self) { [weak self] newValue in
			c.constant = newValue
			self?.view().needsUpdateConstraints = true
		}

		self.bindings.append(self, widthBinder)

		return self
	}

	/// Bind the element's height
	/// - Parameters:
	///   - widthBinder: The height binder
	///   - priority: The autolayout priority
	/// - Returns: self
	@discardableResult func bindHeight(
		_ heightBinder: ValueBinder<Double>,
		priority: NSLayoutConstraint.Priority? = nil
	) -> Self {

		guard allHeightConstraints.isEmpty else {
			assert(false, "Attempting to bind height constraint to an element with a fixed height already assigned")
			return self
		}

		let view = self.view()

		let c = NSLayoutConstraint(
			item: view, attribute: .height,
			relatedBy: .equal,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1, constant: heightBinder.wrappedValue
		)
		c.identifier = "forcedHeight"
		if let p = priority { c.priority = p }
		view.addConstraint(c)

		heightBinder.register(self) { [weak self] newValue in
			c.constant = newValue
			self?.view().needsUpdateConstraints = true
		}

		self.bindings.append(self, heightBinder)

		return self
	}
}
