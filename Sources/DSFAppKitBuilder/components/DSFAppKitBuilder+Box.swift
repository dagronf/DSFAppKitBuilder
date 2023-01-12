//
//  DSFAppKitBuilder+Box.swift
//
// Copyright © 2023 Darren Ford. All rights reserved.
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
		_ builder: () -> Element) {
			self.init(
				title,
				titlePosition: titlePosition,
				content: builder())
	}

	/// Create a box
	/// - Parameters:
	///   - title: The title of the box
	///   - titlePosition: The position of the title within the box
	///   - content: An array of elements to use for the box content
	public init(
		_ title: String,
		titlePosition: NSBox.TitlePosition = .atTop,
		content: Element)
	{
		self.content = content
		super.init()

		containerView.autoresizingMask = [.width, .height]

		boxView.contentView = containerView
		containerView.addSubview(content.view())
		content.view().pinEdges(to: containerView)
		containerView.needsLayout = true

		boxView.title = title
		boxView.titlePosition = titlePosition

		boxView.needsLayout = true
		boxView.layoutSubtreeIfNeeded()
	}

	// Private
	private let boxView = NSBox()
	public override func view() -> NSView { return self.boxView }
	public override func childElements() -> [Element] {
		return [self.content]
	}
	private let containerView = NSView()
	private let content: Element
}

// MARK: - Modifiers

public extension Box {
	/// Set the font for the box title
	func titleFont(_ font: NSFont) -> Self {
		self.boxView.titleFont = font
		return self
	}
}
