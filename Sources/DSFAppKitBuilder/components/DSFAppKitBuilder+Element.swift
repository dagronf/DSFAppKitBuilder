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

/// The base element.
public class Element: NSObject {

	/// Called when the view is added to a parent.
	public func addedToParentView(parent: NSView) {
		// Default -- do nothing
		// Can be overriden in inherited classes if needed
	}

	// Private

	internal override init() {
		super.init()
		self.nsView.wantsLayer = true
		self.nsView.translatesAutoresizingMaskIntoConstraints = false
	}

	var nsView: NSView { fatalError() }
	var nsLayer: CALayer? { return self.nsView.layer }

	private lazy var isHiddenBinder = Bindable<Bool>()
}

// MARK: - Modifiers

public extension Element {
	/// Set the tooltip to be displayed for this control
	func toolTip(_ tip: String) -> Self {
		self.nsView.toolTip = tip
		return self
	}

	/// Set the background color
	func backgroundColor(_ color: NSColor) -> Self {
		self.nsLayer?.backgroundColor = color.cgColor
		return self
	}

	/// Set the border width and color for the element
	func border(width: CGFloat, color: NSColor) -> Self {
		self.nsLayer?.borderColor = color.cgColor
		self.nsLayer?.borderWidth = width
		return self
	}

	/// Set the corner radius for the element
	func cornerRadius(_ amount: CGFloat) -> Self {
		self.nsLayer?.cornerRadius = amount
		return self
	}

	/// Block to call when the element is configured.  The block will be passed the embedded AppKit control
	func additionalAppKitControlSettings<VIEWTYPE>(_ block: (VIEWTYPE) -> Void) -> Self {
		block(self.nsView as! VIEWTYPE)
		return self
	}
}

// MARK: - Dimensions

public extension Element {
	/// Set the width of the element
	func width(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		let c = NSLayoutConstraint(item: nsView, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
		if let p = priority { c.priority = p }
		self.nsView.addConstraint(c)
		return self
	}

	/// Set the width of the element
	func width(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(value, relation: .equal, priority: priority)
	}

	/// Set the minimum width of the element
	func minWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(value, relation: .greaterThanOrEqual, priority: priority)
	}

	/// Set the maximum width of the element
	func maxWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(value, relation: .lessThanOrEqual, priority: priority)
	}

	/// Set the height of the element
	func height(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		let c = NSLayoutConstraint(item: nsView, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
		if let p = priority { c.priority = p }
		self.nsView.addConstraint(c)
		return self
	}

	/// Set the height of the element
	func height(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.height(value, relation: .equal, priority: priority)
	}

	/// Set the minimum height of the element
	func minHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.height(value, relation: .greaterThanOrEqual, priority: priority)
	}

	/// Set the maximum height of the element
	func maxHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.height(value, relation: .lessThanOrEqual, priority: priority)
	}

	/// Set a size for the element
	func size(width: CGFloat, height: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(width, priority: priority).height(height, priority: priority)
	}

}

// MARK: - Binding

public extension Element {
	/// Binding for showing or hiding the element
	func bindIsHidden<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Bool>) -> Self {
		self.isHiddenBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.nsView.isHidden = newValue
		})
		return self
	}
}

// MARK: - Result Builder for stacks

#if swift(<5.3)
@_functionBuilder
public enum ElementBuilder {
	static func buildBlock() -> [Element] { [] }
}
#else
@resultBuilder
public enum ElementBuilder {
	static func buildBlock() -> [Element] { [] }
}
#endif

public extension ElementBuilder {
	static func buildBlock(_ settings: Element...) -> [Element] {
		settings
	}
}
