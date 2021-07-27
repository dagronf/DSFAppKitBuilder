//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSStackView

#if swift(<5.3)
@_functionBuilder
public struct StackBuilder {
	static func buildBlock() -> [SwiftDSLElement] { [] }
}
#else
@resultBuilder
public struct StackBuilder {
	static func buildBlock() -> [Element] { [] }
}
#endif

public extension StackBuilder {
	static func buildBlock(_ settings: Element...) -> [Element] {
		settings
	}
}

public class Stack: Element {
	public override var nsView: NSView { return self.stack }
	let stack = NSStackView()

	let content: [Element]

	internal init(
		tag: Int? = nil,
		orientation: NSUserInterfaceLayoutOrientation,
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute,
		content: [Element])
	{
		self.content = content
		super.init(tag: tag)
		self.stack.spacing = spacing
		self.stack.orientation = orientation
		self.stack.alignment = alignment
		content.forEach { stack.addArrangedSubview($0.nsView) }

		self.stack.needsLayout = true
		self.stack.needsUpdateConstraints = true
	}

	public func spacing(_ spacing: CGFloat) -> Self {
		self.stack.spacing = spacing
		return self
	}

	public func distribution(_ dist: NSStackView.Distribution) -> Self {
		self.stack.distribution = dist
		return self
	}

	public func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
		self.stack.alignment = alignment
		return self
	}

	public func hugging(h: NSLayoutConstraint.Priority? = nil, v: NSLayoutConstraint.Priority? = nil) -> Self {
		if let h = h {
			self.nsView.setContentHuggingPriority(h, for: .horizontal)
		}
		if let v = v {
			self.nsView.setContentHuggingPriority(v, for: .vertical)
		}
		return self
	}

	// MARK: - Edge insets

	public func edgeInsets(_ edgeInsets: NSEdgeInsets) -> Self {
		self.stack.edgeInsets = edgeInsets
		return self
	}

	public func edgeInsets(_ value: CGFloat) -> Self {
		return edgeInsets(NSEdgeInsets(top: value, left: value, bottom: value, right: value))
	}

}

public class VStack: Stack {
	public init(
		tag: Int? = nil,
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute = .centerX,
		content: [Element]) {
			super.init(tag: tag,
						  orientation: .vertical,
						  spacing: spacing,
						  alignment: alignment,
						  content: content)
		}

	public convenience init(
		tag: Int? = nil,
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute = .centerX,
		@StackBuilder builder: () -> [Element]
	) {
		self.init(
			tag: tag,
			spacing: spacing,
			alignment: alignment,
			content: builder())
	}
}

public class HStack: Stack {
	public init(
		tag: Int? = nil,
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute = .centerY,
		content: [Element]) {
			super.init(
				tag: tag,
				orientation: .horizontal,
				spacing: spacing,
				alignment: alignment,
				content: content)
		}

	public convenience init(
		tag: Int? = nil,
		spacing: CGFloat = 8,
		alignment: NSLayoutConstraint.Attribute = .centerY,
		@StackBuilder builder: () -> [Element]
	) {
		self.init(
			tag: tag,
			spacing: spacing,
			alignment: alignment,
			content: builder())
	}
}
