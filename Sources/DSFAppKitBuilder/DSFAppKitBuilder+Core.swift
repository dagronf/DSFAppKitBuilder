//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
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

	public func width(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		let c = NSLayoutConstraint(item: nsView, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
		if let p = priority { c.priority = p }
		nsView.addConstraint(c)
		return self
	}
	@inlinable public func width(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return width(value, relation: .equal, priority: priority)
	}
	@inlinable public func minWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return width(value, relation: .greaterThanOrEqual, priority: priority)
	}
	@inlinable public func maxWidth(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return width(value, relation: .lessThanOrEqual, priority: priority)
	}

	// MARK: - Height

	public func height(_ value: CGFloat, relation: NSLayoutConstraint.Relation = .equal, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		let c = NSLayoutConstraint(item: nsView, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
		if let p = priority { c.priority = p }
		nsView.addConstraint(c)
		return self
	}
	@inlinable public func height(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return height(value, relation: .equal, priority: priority)
	}
	@inlinable public func minHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return height(value, relation: .greaterThanOrEqual, priority: priority)
	}
	@inlinable public func maxHeight(_ value: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return height(value, relation: .lessThanOrEqual, priority: priority)
	}

	// MARK: - Size

	public func size(width: CGFloat, height: CGFloat, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		return self.width(width, priority: priority).height(height, priority: priority)
	}

	// MARK: - Tooltip

	/// Set the tooltip to be displayed for this control
	public func toolTip(_ tip: String) -> Self {
		self.nsView.toolTip = tip
		return self
	}

	// MARK: - Autolayout

	/// Set the content hugging for the element.
	public func contentHugging(h: NSLayoutConstraint.Priority? = nil, v: NSLayoutConstraint.Priority? = nil) -> Self {
		if let h = h {
			self.nsView.setContentHuggingPriority(h, for: .horizontal)
		}
		if let v = v {
			self.nsView.setContentHuggingPriority(v, for: .vertical)
		}
		return self
	}

	/// Set the content compression resistance for the element.
	public func contentCompressionResistance(h: NSLayoutConstraint.Priority? = nil, v: NSLayoutConstraint.Priority? = nil) -> Self {
		if let h = h {
			self.nsView.setContentCompressionResistancePriority(h, for: .horizontal)
		}
		if let v = v {
			self.nsView.setContentCompressionResistancePriority(v, for: .vertical)
		}
		return self
	}

	// MARK: Fallback settings

	public func additional<ViewType: NSView>(_ block: (ViewType) -> Void) -> Self {
		block(self.nsView as! ViewType)
		return self
	}
}

/// A DSL Element that is a control (ie. it is interactive in some way, like a button)
public class Control: Element {
	var control: NSControl { return nsView as! NSControl }

	// Block the initializer so can't be created outside the package
	internal override init(tag: Int? = nil) {
		super.init(tag: tag)
	}

	/// Set the enabled state for the control
	public func isEnabled(_ isEnabled: Bool) -> Self {
		control.isEnabled = isEnabled
		return self
	}

	/// Set the control size for the element
	public func controlSize(_ controlSize: NSControl.ControlSize) -> Self {
		self.control.controlSize = controlSize
		return self
	}

	private lazy var isEnabledBinder = Bindable<Bool>()

	/// Binding for isEnabled
	public func bindIsEnabled<TYPE: NSObject>(_ object: TYPE, keyPath: ReferenceWritableKeyPath<TYPE, Bool>) -> Self {
		self.isEnabledBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.control.isEnabled = newValue
		})
		self.isEnabledBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}
}
