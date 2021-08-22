//
//  DSFAppKitBuilder+Group.swift
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

/// A simple grouping wrapper allowing edge insets
///
/// Usage:
///
/// ```swift
/// Group(edgeOffset: 20) {
///    Label("This is exciting")
/// }
/// ```
public class Group: Element {
	/// Create a group instance
	/// - Parameters:
	///   - edgeInset: The inset value for all edges for the child eleemnt
	///   - visualEffect: Use a NSVisualEffectView as the container view
	///   - builder: The builder for generating the group's content
	@inlinable public convenience init(
		edgeInset: CGFloat = 0,
		layoutType: EmbeddedLayoutType = .pinEdges,
		visualEffect: VisualEffect? = nil,
		builder: () -> Element
	) {
		self.init(edgeInsets: NSEdgeInsets(edgeInset: edgeInset),
					 layoutType: layoutType,
					 visualEffect: visualEffect,
					 builder: builder)
	}

	/// Create a group instance
	/// - Parameters:
	///   - edgeInsets: The insets for the child element
	///   - visualEffect: Use a NSVisualEffectView as the container view
	///   - builder: The builder for generating the group's content
	public init(
		edgeInsets: NSEdgeInsets,
		layoutType: EmbeddedLayoutType = .pinEdges,
		visualEffect: VisualEffect? = nil,
		builder: () -> Element
	) {
		self.containerView = visualEffect?.makeView() ?? NSView()
		self.containerView.translatesAutoresizingMaskIntoConstraints = false

		let element = builder()

		self.containedElement = element
		super.init()

		let childView = element.view()
		self.containerView.addSubview(childView)

		if layoutType == .pinEdges {
			childView.pinEdges(to: self.containerView, edgeInsets: edgeInsets)
		}
		else if layoutType == .center {
			childView.center(in: self.containerView, edgeInsets: edgeInsets)
		}
	}

	deinit {
		Swift.print("ehhehehehehe")
	}

	// Private

	override public func view() -> NSView { return self.containerView }
	private let containerView: NSView
	private let containedElement: Element
}
