//
//  Box.swift
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

/// An NSBox element
///
/// Usage:
///
/// ```swift
/// Box("My Box Title") {
///    VStack {
///       ...
///    }
/// }
/// ```
public class Box: Element {
	/// Create a box
	/// - Parameters:
	///   - title: The title of the box
	///   - titlePosition: The position of the title within the box
	///   - builder: The builder for the box content
	public convenience init(
		_ title: String,
		titlePosition: NSBox.TitlePosition = .atTop,
		font: AKBFont? = nil,
		_ builder: () -> Element
	) {
		self.init(
			title,
			titlePosition: titlePosition,
			content: builder())
	}

	/// Create a box without a title
	/// - Parameter builder: The builder for the box content
	public convenience init(_ builder: () -> Element) {
		self.init("", titlePosition: .noTitle, content: builder())
	}

	/// Create a box
	/// - Parameters:
	///   - title: The title of the box
	///   - titlePosition: The position of the title within the box
	///   - content: An array of elements to use for the box content
	public init(
		_ title: String,
		titlePosition: NSBox.TitlePosition = .atTop,
		font: AKBFont? = nil,
		content: Element
	) {
		self.content = content
		super.init()

		let contentView = content.view()

		self.boxContent.addSubview(contentView)
		contentView.pinEdges(to: self.boxContent)

		boxView.title = title
		boxView.titlePosition = titlePosition

		if let font = font {
			boxView.titleFont = font.font
		}

		boxView.needsLayout = true
		boxView.layoutSubtreeIfNeeded()
	}

	deinit {
		if self.hasDynamicFont {
			DynamicFontService.shared.deregister(self)
		}
	}

	// Private
	private let boxView = NSBox()
	private var boxContent: NSView { return boxView.contentView! }
	public override func view() -> NSView { return self.boxView }
	public override func childElements() -> [Element] { [content] }
	private let content: Element
	private var hasDynamicFont: Bool = false
}

// MARK: - Modifiers

public extension Box {
	/// Set the font for the box title
	func titleFont(_ font: NSFont) -> Self {
		self.boxView.titleFont = font
		return self
	}

	/// Set the font for the box title
	func titleFont(_ font: AKBFont) -> Self {
		self.boxView.titleFont = font.font
		return self
	}

	func dynamicFont(_ font: DynamicFont) -> Self {
		DynamicFontService.shared.register(self, font: font) { [weak self] newFont in
			self?.boxView.titleFont = newFont
		}
		self.hasDynamicFont = true
		return self
	}
}

// MARK: - FakeBox

/// A fake box-style element which handles autolayout slightly better
public class FakeBox: Element {
	public init(_ title: String, font: AKBFont? = nil, @ElementBuilder builder: () -> [Element]) {
		let font = font ?? AKBFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize))
		self.body = Nothing()
		super.init()
		self.body = VStack(spacing: 1, alignment: .leading) {
			Label(title)
				.labelPadding(NSEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
				.font(font)
				.applyStyle(Label.Styling.truncatingTail)
				.horizontalHuggingPriority(1)
				.bindElement(self.binder)
			VStack(spacing: 8, alignment: .leading, elements: builder())
				.stackPadding(6)
				.cornerRadius(6)
				.border(width: 0.5, color: NSColor.quaternaryLabelColor)
				.backgroundColor(NSColor.quaternaryLabelColor.withAlphaComponent(0.05))
				.hugging(h: 1)
		}
		.hugging(h: 1)
		.accessibility([.group(title)])
	}

	public init(_ title: String, font: AKBFont? = nil, _ content: Element) {
		let font = font ?? AKBFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize))
		self.body = Nothing()
		super.init()
		self.body = VStack(spacing: 1, alignment: .leading) {
			Label(title)
				.labelPadding(NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 0))
				.font(font)
				.applyStyle(Label.Styling.truncatingTail)
				.horizontalHuggingPriority(1)
				.bindElement(self.binder)
			content
				.cornerRadius(6)
				.border(width: 0.5, color: NSColor.quaternaryLabelColor)
				.backgroundColor(NSColor.quaternaryLabelColor.withAlphaComponent(0.05))
				.horizontalHuggingPriority(1)
		}
		.hugging(h: 1)
		.accessibility([.group(title)])
	}

	deinit {
		if self.hasDynamicFont {
			DynamicFontService.shared.deregister(self)
		}
	}

	var body: Element
	var hasDynamicFont = false
	private let binder = ElementBinder()
	public override func view() -> NSView { self.body.view() }
	override public func childElements() -> [Element] { [self.body] }
}

// MARK: - Modifiers

public extension FakeBox {
	/// Set a dynamic font for the title of the box
	func dynamicFont(_ font: DynamicFont) -> Self {
		DynamicFontService.shared.register(self, font: font) { [weak self] newFont in
			guard let l = self?.binder.element as? Label else { fatalError() }
			l.label.font = newFont
		}
		self.hasDynamicFont = true
		return self
	}
}

