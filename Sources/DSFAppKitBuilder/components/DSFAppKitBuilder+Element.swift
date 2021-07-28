//
//  DSFAppKitBuilder+Element.swift
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

import AppKit.NSView

public class Element: NSObject {
	let tag: Int?

	public var nsView: NSView {
		fatalError()
	}

	public init(tag: Int? = nil) {
		self.tag = tag
		super.init()
		self.nsView.wantsLayer = true
		self.nsView.translatesAutoresizingMaskIntoConstraints = false
	}

	private lazy var isHiddenBinder = Bindable<Bool>()

	/// Binding for showing or hiding the element
	public func bindIsHidden<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Bool>) -> Self {
		self.isHiddenBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.nsView.isHidden = newValue
		})
		self.isHiddenBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	// MARK: - Tooltip

	/// Set the tooltip to be displayed for this control
	public func toolTip(_ tip: String) -> Self {
		self.nsView.toolTip = tip
		return self
	}

	/// Set the background color
	@inlinable public func backgroundColor(_ color: NSColor) -> Self {
		self.nsView.layer?.backgroundColor = color.cgColor
		return self
	}

	/// Set the corner radius for the element
	@inlinable public func cornerRadius(_ amount: CGFloat) -> Self {
		self.nsView.layer?.cornerRadius = amount
		return self
	}

	// MARK: - Width

	/// Set the width of the element
	public func width(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		let c = NSLayoutConstraint(item: nsView, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
		if let p = priority { c.priority = p }
		nsView.addConstraint(c)
		return self
	}

	/// Set the width of the element
	@inlinable public func width(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return width(value, relation: .equal, priority: priority)
	}
	/// Set the minimum width of the element
	@inlinable public func minWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return width(value, relation: .greaterThanOrEqual, priority: priority)
	}
	/// Set the maximum width of the element
	@inlinable public func maxWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return width(value, relation: .lessThanOrEqual, priority: priority)
	}

	// MARK: - Height

	/// Set the height of the element
	public func height(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		let c = NSLayoutConstraint(item: nsView, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
		if let p = priority { c.priority = p }
		nsView.addConstraint(c)
		return self
	}
	/// Set the height of the element
	@inlinable public func height(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return height(value, relation: .equal, priority: priority)
	}
	/// Set the minimum height of the element
	@inlinable public func minHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return height(value, relation: .greaterThanOrEqual, priority: priority)
	}
	/// Set the maximum height of the element
	@inlinable public func maxHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return height(value, relation: .lessThanOrEqual, priority: priority)
	}

	// MARK: - Size

	/// Set a size for the element
	@inlinable public func size(width: CGFloat, height: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(width, priority: priority).height(height, priority: priority)
	}

	// MARK: - Hack to handle silly sizing of split view

	public func addedToParentView(_ parentView: NSView) {
		// Default -- do nothing
	}

}


