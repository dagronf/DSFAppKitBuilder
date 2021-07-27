//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSTextField

public class Label: Control {
	let label = NSTextField()
	public override var nsView: NSView { return self.label }

	public init(tag: Int? = nil, _ label: String? = nil) {
		super.init(tag: tag)
		self.label.isEditable = false
		self.label.drawsBackground = false
		self.label.isBezeled = false
		if let l = label { self.label.stringValue = l }
	}

	public func label(_ label: String) -> Self {
		self.label.stringValue = label
		return self
	}

	private lazy var labelBinder = Bindable<String>()
	public func bindLabel<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.labelBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.label.stringValue = newValue
		})
		self.labelBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	public func font(_ font: NSFont? = nil) -> Self {
		self.label.font = font
		return self
	}

	// MARK: - Text Color

	public func textColor(_ textColor: NSColor? = nil) -> Self {
		self.label.textColor = textColor
		return self
	}

	private lazy var textColorAnimator = NSColor.Animator()
	private lazy var textColorBinder = Bindable<NSColor>()
	public func bindTextColor<TYPE>(_ object: NSObject,
											  keyPath: ReferenceWritableKeyPath<TYPE, NSColor>,
											  animated: Bool = false) -> Self {
		self.textColorBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			guard let `self` = self else { return }
			if animated {
				self.textColorAnimator.animate(from: self.label.textColor ?? .clear, to: newValue) { [weak self] color in
					self?.label.textColor = color
				}
			}
			else {
				self.label.textColor = newValue
			}
		})
		return self
	}

	public func isSelectable(_ s: Bool) -> Self {
		self.label.isSelectable = s
		return self
	}

	public func isBordered(_ s: Bool) -> Self {
		self.label.isBordered = s
		return self
	}

	public func isBezeled(_ s: Bool) -> Self {
		self.label.isBezeled = s
		return self
	}

	public func drawsBackground(_ s: Bool) -> Self {
		self.label.drawsBackground = s
		return self
	}

	public func alignment(_ alignment: NSTextAlignment) -> Self {
		self.label.alignment = alignment
		return self
	}

	public func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
		self.label.cell?.lineBreakMode = mode
		return self
	}

	public func allowsDefaultTighteningForTruncation(_ allow: Bool) -> Self {
		self.label.allowsDefaultTighteningForTruncation = allow
		return self
	}
}
