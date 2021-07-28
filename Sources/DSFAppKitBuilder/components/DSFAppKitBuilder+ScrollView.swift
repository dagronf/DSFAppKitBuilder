//
//  File.swift
//  File
//
//  Created by Darren Ford on 28/7/21.
//

import AppKit

final class FlippedClipView: NSClipView {
	override var isFlipped: Bool {
		return true
	}
}

/// Embed another NSView within the DSL
public class ScrollView: Element {
	let scrollView = NSScrollView()

	let content = NSStackView()

	let documentElements: [Element]

	override public var nsView: NSView { return self.scrollView }

	/// Create a ScrollView
	/// - Parameters:
	///   - tag: (optional) The identifing tag
	///   - fitHorizontally: Set the width of the content to the width of the scrollview
	///   - autohidesScrollers: A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	///   - documentElement: The content of the scrollview
	convenience public init(
		tag: Int? = nil,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		@StackBuilder builder: () -> [Element]
	) {
		self.init(
			tag: tag,
			fitHorizontally: fitHorizontally,
			autohidesScrollers: autohidesScrollers,
			contents: builder())
	}

	/// Create a ScrollView
	/// - Parameters:
	///   - tag: (optional) The identifing tag
	///   - fitHorizontally: Set the width of the content to the width of the scrollview
	///   - autohidesScrollers: A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	///   - documentElement: The content of the scrollview
	public init(
		tag: Int? = nil,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		contents: [Element]
	) {
		self.documentElements = contents
		super.init(tag: tag)

		self.setup(fitHorizontally: fitHorizontally,
		           autohidesScrollers: autohidesScrollers)
	}

	public func autohidesScrollers(_ autohidesScrollers: Bool) -> Self {
		self.scrollView.autohidesScrollers = autohidesScrollers
		return self
	}

	public func borderType(_ type: NSBorderType) -> Self {
		self.scrollView.borderType = type
		return self
	}
}

private extension ScrollView {
	func setup(
		fitHorizontally: Bool,
		autohidesScrollers: Bool)
	{

		self.content.translatesAutoresizingMaskIntoConstraints = false
		self.content.orientation = .vertical
		self.content.alignment = .leading

		self.documentElements.forEach { element in
			self.content.addArrangedSubview(element.nsView)
		}


		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.borderType = .noBorder
		self.scrollView.backgroundColor = NSColor.gray

		self.scrollView.autohidesScrollers = autohidesScrollers
		self.scrollView.hasVerticalScroller = true

		if !fitHorizontally {
			self.scrollView.hasHorizontalScroller = true
		}

		let clipView = FlippedClipView()
		clipView.drawsBackground = false
		self.scrollView.contentView = clipView
		clipView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			clipView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
			clipView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
			clipView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			clipView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
		])

		self.scrollView.documentView = self.content

		NSLayoutConstraint.activate([
			content.leftAnchor.constraint(equalTo: clipView.leftAnchor),
			content.topAnchor.constraint(equalTo: clipView.topAnchor),
			// NOTE: No need for bottomAnchor
		])

		if fitHorizontally {
			NSLayoutConstraint.activate([
				content.rightAnchor.constraint(equalTo: clipView.rightAnchor),
			])
		}
	}
}
