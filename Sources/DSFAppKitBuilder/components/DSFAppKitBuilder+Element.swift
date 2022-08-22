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
import DSFValueBinders

import DSFAppearanceManager

/// The base element.
open class Element: NSObject {

	/// A unique identifier for the element
	public let id = UUID()

	// Set to true in derived classes to receive a callback when the system theme changes
	internal var receiveThemeNotifications = false {
		willSet {
			self.updateReceiveThemeNotifications(to: newValue)
		}
	}

	/// Overridden in derived classes to provide custom first responder behaviour
	open func makeFirstResponder() {
		let v = self.view()
		if let w = v.window {
			w.makeFirstResponder(v)
		}
	}

	/// Return the bounds rect for the nsView control
	@inlinable public var bounds: CGRect {
		return self.view().bounds
	}

	/// Return the frame rect for the nsView control
	@inlinable public var frame: CGRect {
		return self.view().frame
	}

	// Private

	// Default constructor - should only be called from a derived class
	override public init() {
		super.init()
		with(self.view()) {
			$0.wantsLayer = true
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
	}

	deinit {
		self.receiveThemeNotifications = false
		self.isHiddenBinder?.deregister(self)
		Logger.Debug("Element [\(type(of: self))] deinit")
	}

	/// Overridden in derived classes to return the root AppKit type for the element
	open func view() -> NSView { fatalError() }

	/// Overridden in derived classes to return the child elements of this element
	open func childElements() -> [Element] { return [] }

	// Returns the layer defined for the root AppKit element view type
	var nsLayer: CALayer? { return self.view().layer }

	// MARK: Binding

	private var isHiddenBinder: ValueBinder<Bool>?

	// CGColor convertibles
	private var _backgroundColor: NSColor?
	private var _borderColor: NSColor?
}

// MARK: - Dark mode handling

extension Element: DSFAppearanceCacheNotifiable {
	// Called when the element is setting the 'receiveThemeNotifications' value
	private func updateReceiveThemeNotifications(to newValue: Bool) {
		if newValue == self.receiveThemeNotifications {
			// No change -- just ignore
			return
		}

		if newValue == true {
			// Start listening for theme changes
			DSFAppearanceCache.shared.register(self)
		}
		else {
			// Stop listening
			DSFAppearanceCache.shared.deregister(self)
		}
	}

	public func appearanceDidChange() {
		// Protocol guarantees that this will be called on the main thread
		assert(Thread.isMainThread)

		// Make sure we use the appearance of the view to handle drawing, or else it may not take effect
		UsingEffectiveAppearance(of: self.view()) { _ in
			self.onThemeChange()
		}
	}

	/// Called when the system's theme has changed. Guaranteed to be called on the main thread.
	///
	/// Override this in inherited classes if you need to tweak appearances for display mode.
	/// The `Element` must have called `enableThemeChangeNotification()` to receive this call.
	///
	/// You must always call `super.onThemeChange()` from within your override.
	public func onThemeChange() {
		assert(Thread.isMainThread)

		// Any setting that uses cgColor to provide the color will not automatically be updated
		// when the theme changes.  NSColor provides magic to handle the theme change, but as soon
		// as you 'tweak' the color (eg. via calling cgColor) the auto magic is lost.
		//
		// As such, as layers use `CGColor`s, we need to handle this change ourselves for any settings
		// that use `CGColor` under the hood

		if let b = self._backgroundColor {
			self.nsLayer?.backgroundColor = b.cgColor
		}
		if let c = self._borderColor {
			self.nsLayer?.borderColor = c.cgColor
		}
	}
}

// MARK: - Modifiers

public extension Element {
	/// Set the tooltip to be displayed for this control
	@discardableResult
	func toolTip(_ tip: String) -> Self {
		self.view().toolTip = tip
		return self
	}

	/// Set the background color
	@discardableResult
	func backgroundColor(_ color: NSColor) -> Self {
		self.receiveThemeNotifications = true // Background color uses CGColor, so we have to update manually
		self._backgroundColor = color
		self.nsLayer?.backgroundColor = color.cgColor
		return self
	}

	/// Set the border width and color for the element
	@discardableResult
	func border(width: CGFloat, color: NSColor) -> Self {
		self.receiveThemeNotifications = true // Border color uses CGColor, so we have to update manually
		self._borderColor = color
		self.nsLayer?.borderColor = color.cgColor
		self.nsLayer?.borderWidth = width
		return self
	}

	/// Set the corner radius for the element
	@discardableResult
	func cornerRadius(_ amount: CGFloat) -> Self {
		self.nsLayer?.cornerRadius = amount
		return self
	}

	/// Add a shadow to the element
	/// - Parameters:
	///   - radius: The blur radius used to create the shadow
	///   - offset: The offset (in points) of the layer’s shadow
	///   - color: The color of the layer’s shadow
	///   - opacity: The opacity of the layer’s shadow
	/// - Returns: Self
	@discardableResult
	func shadow(
		radius: CGFloat = 3,
		offset: CGSize = CGSize(width: 0, height: -3),
		color: NSColor = .shadowColor,
		opacity: CGFloat = 0.5
	) -> Self {
		using(self.nsLayer) {
			$0.shadowRadius = radius
			$0.shadowOffset = offset
			$0.shadowColor = color.cgColor
			$0.shadowOpacity = Float(opacity)
			$0.masksToBounds = false
		}
		return self
	}

	/// Add a shadow to the element
	/// - Parameters:
	///   - shadow: A shadow object describing the shadow
	/// - Returns: Self
	@discardableResult
	@inlinable func shadow(_ shadow: Shadow) -> Self {
		self.shadow(
			radius: shadow.radius,
			offset: shadow.offset,
			color: shadow.color,
			opacity: shadow.opacity
		)
	}
}

public extension Element {
	/// Apply a block function recursively over the element and all of its children
	@discardableResult
	func applyRecursively(_ block: (Element) -> Void) -> Self {
		block(self)
		self.childElements().forEach { element in
			element.applyRecursively(block)
		}
		return self
	}

	/// Provide a block to call _after_ the element is created and the embedded AppKit control is initially available.
	@discardableResult
	func additionalAppKitControlSettings<VIEWTYPE>(_ block: (VIEWTYPE) -> Void) -> Self {
		block(self.view() as! VIEWTYPE)
		return self
	}
}

// MARK: - Dimensions

public extension Element {
	/// Set a size for the element
	/// - Parameters:
	///   - width: The width for the element
	///   - height: The height for the element
	///   - priority: The priority to apply to both the width and the height
	/// - Returns: Self
	@discardableResult
	func size(width: CGFloat, height: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(width, priority: priority).height(height, priority: priority)
	}
}

// MARK: Width setting

public extension Element {
	/// Set the width of the element
	@discardableResult
	func width(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		with(self.view()) {
			let c = NSLayoutConstraint(item: $0, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
			if let p = priority { c.priority = p }
			$0.addConstraint(c)
		}
		return self
	}

	/// Set the width of the element
	@discardableResult
	func width(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(value, relation: .equal, priority: priority)
	}

	/// Set the minimum width of the element
	@discardableResult
	func minWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(value, relation: .greaterThanOrEqual, priority: priority)
	}

	/// Set the maximum width of the element
	@discardableResult
	func maxWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(value, relation: .lessThanOrEqual, priority: priority)
	}
}

// MARK: Height setting

public extension Element {
	/// Set the height of the element
	@discardableResult
	func height(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		with(self.view()) {
			let c = NSLayoutConstraint(item: $0, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
			if let p = priority { c.priority = p }
			$0.addConstraint(c)
		}
		return self
	}

	/// Set the height of the element
	@discardableResult
	func height(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.height(value, relation: .equal, priority: priority)
	}

	/// Set the minimum height of the element
	@discardableResult
	func minHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.height(value, relation: .greaterThanOrEqual, priority: priority)
	}

	/// Set the maximum height of the element
	@discardableResult
	func maxHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.height(value, relation: .lessThanOrEqual, priority: priority)
	}
}

// MARK: - Binding

public extension Element {
	/// Binding for showing or hiding the element
	@discardableResult
	func bindIsHidden(_ isHiddenBinder: ValueBinder<Bool>) -> Self {
		self.isHiddenBinder = isHiddenBinder
		isHiddenBinder.register { [weak self] newValue in
			self?.view().isHidden = newValue
		}
		return self
	}

	/// Bind this element to an ElementBinder
	@discardableResult
	func bindElement(_ elementBinder: ElementBinder) -> Self {
		elementBinder.element = self
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
