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
open class Element: NSObject {

	// Set to true in derived classes to receive a callback when the system theme changes
	internal var receiveThemeNotifications = false {
		willSet {
			self.updateReceiveThemeNotifications(to: newValue)
		}
	}

	/// Overridden in derived classes to return the root AppKit type for the element
	open func view() -> NSView { fatalError() }

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
	public override init() {
		super.init()
		with(self.view()) {
			$0.wantsLayer = true
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
	}

	deinit {
		self.receiveThemeNotifications = false
		Logger.Debug("Element [\(type(of: self))] deinit")
	}

	// Returns the layer defined for the root AppKit element view type
	var nsLayer: CALayer? { return self.view().layer }

	// MARK: Binding

	private var isHiddenBinder: ValueBinder<Bool>?

	// CGColor convertibles
	private var _backgroundColor: NSColor?
	private var _borderColor: NSColor?
}

// MARK: - Dark mode handling

extension Element {

	// Called when the element is setting the 'receiveThemeNotifications' value
	private func updateReceiveThemeNotifications(to newValue: Bool) {
		if newValue == self.receiveThemeNotifications {
			// No change -- just ignore
			return
		}

		if newValue == true {
			// Start listening for theme changes
			ThemeNotificationCenter.addObserver(
				self,
				selector: #selector(self.themeChange),
				name: NSNotification.Name.ThemeChangedNotification,
				object: nil
			)
		}
		else {
			// Stop listening
			ThemeNotificationCenter.removeObserver(
				self,
				name: NSNotification.Name.ThemeChangedNotification,
				object: nil)
		}
	}

	// Called when the system theme has changed AND the element has called
	@objc private func themeChange() {
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }

			// Make sure we use the appearance of the view to handle drawing, or else it may not take effect
			UsingEffectiveAppearance(of: self.view()) {
				self.onThemeChange()
			}
		}
	}

	/// Called when the system's theme has changed. Guaranteed to be called on the main thread.
	///
	/// Override this in inherited classes if you need to tweak appearances for display mode.
	/// The `Element` must have called `enableThemeChangeNotification()` to receive this call.
	///
	/// You must always call `super.onThemeChange()` from within your override.
	open func onThemeChange() {
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
	func toolTip(_ tip: String) -> Self {
		self.view().toolTip = tip
		return self
	}

	/// Set the background color
	func backgroundColor(_ color: NSColor) -> Self {
		self.receiveThemeNotifications = true   // Background color uses CGColor, so we have to update manually
		_backgroundColor = color
		self.nsLayer?.backgroundColor = color.cgColor
		return self
	}

	/// Set the border width and color for the element
	func border(width: CGFloat, color: NSColor) -> Self {
		self.receiveThemeNotifications = true   // Border color uses CGColor, so we have to update manually
		_borderColor = color
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
		block(self.view() as! VIEWTYPE)
		return self
	}
}

// MARK: - Dimensions

public extension Element {
	/// Set the width of the element
	func width(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		with(self.view()) {
			let c = NSLayoutConstraint(item: $0, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
			if let p = priority { c.priority = p }
			$0.addConstraint(c)
		}
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
		with(self.view()) {
			let c = NSLayoutConstraint(item: $0, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
			if let p = priority { c.priority = p }
			$0.addConstraint(c)
		}
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
	func bindIsHidden(_ isHiddenBinder: ValueBinder<Bool>) -> Self {
		self.isHiddenBinder = isHiddenBinder
		isHiddenBinder.register(self) { [weak self] newValue in
			self?.view().isHidden = newValue
		}
		return self
	}

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
