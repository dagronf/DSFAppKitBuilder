//
//  ScrollView.swift
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

final class FlippedClipView: NSClipView {
	override var isFlipped: Bool {
		return true
	}
}

/// Wrapper for NSScrollView
///
/// Usage:
///
/// ```swift
/// ScrollView(fitHorizontally: true) {
///    VStack(spacing: 16, alignment: .leading) {
///       Label("This is the first line")
///       Label("This is the second line")
///    }
///}
/// ```
public class ScrollView: Element {

	/// Create a ScrollView
	/// - Parameters:
	///   - fitHorizontally: Fix the width of the content to the width of the scrollview (so no horizontal scroller)
	///   - autohidesScrollers: A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	///   - documentElement: The content of the scrollview
	public convenience init(
		borderType: NSBorderType = .lineBorder,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		_ builder: () -> Element
	) {
		self.init(
			borderType: borderType,
			fitHorizontally: fitHorizontally,
			autohidesScrollers: autohidesScrollers,
			content: builder()
		)
	}

	/// Create a ScrollView
	/// - Parameters:
	///   - borderType: A value that specifies the appearance of the scroll view’s border
	///   - fitHorizontally: Set the width of the content to the width of the scrollview
	///   - autohidesScrollers: A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	///   - content: The content of the scrollview
	init(
		borderType: NSBorderType = .lineBorder,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		content: Element
	) {
		self.documentContent = content
		super.init()

		self.setup(
			borderType: borderType,
			fitHorizontally: fitHorizontally,
			autohidesScrollers: autohidesScrollers)
	}

	// Private
	private let scrollView = NSScrollView()
	private let documentContent: Element
	public override func view() -> NSView { return self.scrollView }
	public override func childElements() -> [Element] { return [self.documentContent] } 
}

// MARK: - Modifiers

public extension ScrollView {
	/// A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	func autohidesScrollers(_ autohidesScrollers: Bool) -> Self {
		self.scrollView.autohidesScrollers = autohidesScrollers
		return self
	}

	/// A value that specifies the appearance of the scroll view’s border.
	func borderType(_ type: NSBorderType) -> Self {
		self.scrollView.borderType = type
		return self
	}
}

// MARK: - Private

private extension ScrollView {
	func setup(
		borderType: NSBorderType,
		fitHorizontally: Bool,
		autohidesScrollers: Bool
	) {
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.borderType = .noBorder
		self.scrollView.backgroundColor = .clear
		self.scrollView.drawsBackground = false

		self.scrollView.autohidesScrollers = autohidesScrollers
		self.scrollView.hasVerticalScroller = true
		self.scrollView.borderType = borderType

		if !fitHorizontally {
			self.scrollView.hasHorizontalScroller = true
		}

		let clipView = FlippedClipView()
		clipView.drawsBackground = false
		self.scrollView.contentView = clipView
		clipView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			clipView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			clipView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			clipView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			clipView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
		])

		let contentView = documentContent.view()

		self.scrollView.documentView = contentView

		NSLayoutConstraint.activate([
			contentView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
			contentView.topAnchor.constraint(equalTo: clipView.topAnchor),
			// NOTE: No need for bottomAnchor
		])

		if fitHorizontally {
			NSLayoutConstraint.activate([
				contentView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
			])
		}
	}
}
