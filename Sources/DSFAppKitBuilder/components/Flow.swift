//
//  Flow.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
import Foundation

/// A collection view that flows its child elements horizontally across its visible space
///
/// ```swift
///   Flow(edgeInsets: NSEdgeInsets(edgeInset: 20)) {
///		Button(title: "#earth")
///		Button(title: "#universe")
///		Button(title: "#space")
///		Button(title: "#black_hole")
///	}
/// ```
public class Flow: Element {
	/// Create a flow view
	/// - Parameters:
	///   - minimumInteritemSpacing: The minimum spacing between each item horizontally
	///   - minimumLineSpacing: The minimum spacing between lines
	///   - edgeInsets: The inset to use
	///   - builder: The builder function
	public convenience init(
		minimumInteritemSpacing: CGFloat? = nil,
		minimumLineSpacing: CGFloat? = nil,
		edgeInsets: NSEdgeInsets? = nil,
		layoutDirection: NSUserInterfaceLayoutDirection? = nil,
		@ElementBuilder builder: () -> [Element]
	) {
		self.init(
			minimumInteritemSpacing: minimumInteritemSpacing,
			minimumLineSpacing: minimumLineSpacing,
			edgeInsets: edgeInsets,
			layoutDirection: layoutDirection,
			builder()
		)
	}

	/// Create a flow view
	/// - Parameters:
	///   - minimumInteritemSpacing: The minimum spacing between each item horizontally
	///   - minimumLineSpacing: The minimum spacing between lines
	///   - edgeInsets: The inset to use
	///   - content: The array of elements to display in the flow view
	public init(
		minimumInteritemSpacing: CGFloat? = nil,
		minimumLineSpacing: CGFloat? = nil,
		edgeInsets: NSEdgeInsets? = nil,
		layoutDirection: NSUserInterfaceLayoutDirection? = nil,
		_ content: [Element]
	) {
		self.elements = content
		self.content = content.compactMap {
			let v = $0.view()
			if v is NothingView { return nil }
			return v
		}
		super.init()

		self.collectionView.wantsLayer = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self

		let layout = CollectionViewLeftAlignedFlowLayout()
		layout.direction = layoutDirection ?? self.collectionView.userInterfaceLayoutDirection
		if let minimumInteritemSpacing = minimumInteritemSpacing {
			layout.minimumInteritemSpacing = minimumInteritemSpacing
		}
		if let minimumLineSpacing = minimumLineSpacing {
			layout.minimumLineSpacing = minimumLineSpacing
		}
		if let edgeInsets = edgeInsets {
			layout.sectionInset = edgeInsets
		}

		self.collectionView.needsLayout = true

		self.collectionView.collectionViewLayout = layout
		self.collectionView.reloadData()
	}

	func invalidateLayout() {
		self.collectionView.collectionViewLayout?.invalidateLayout()
	}

	// Private
	private let collectionView = FlowCollectionView()
	private let elements: [Element]
	private let content: [NSView]

	override public func view() -> NSView { return self.collectionView }
	override public func childElements() -> [Element] { self.elements }
}

// MARK: - Modifiers

extension Flow: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
	public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		self.content.count
	}

	public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = FlowCollectionView.CollectionItem()
		item.elementView = self.content[indexPath.item]
		return item
	}

	public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		let view = self.content[indexPath.item]
		return view.fittingSize
	}
}

// MARK: - Custom collection view

// A CollectionView that hugs its content
class FlowCollectionView: NSCollectionView {
	override func reloadData() {
		super.reloadData()
		self.invalidateIntrinsicContentSize()
	}

	override func viewWillMove(toWindow newWindow: NSWindow?) {
		super.viewWillMove(toWindow: newWindow)
		self.backgroundColors = [.clear]
		self.setContentHuggingPriority(.init(10), for: .horizontal)
		self.setContentHuggingPriority(.init(999), for: .vertical)
	}

	override func layout() {
		super.layout()
		self.invalidateIntrinsicContentSize()
	}

	override var intrinsicContentSize: CGSize {
		let intr = self.collectionViewLayout?.collectionViewContentSize ?? .zero
		return CGSize(width: -1, height: intr.height)
	}
}

// MARK: - Flow item

fileprivate extension FlowCollectionView {
	// The collection item
	class CollectionItem: NSCollectionViewItem {
		override func loadView() {
			self.view = NSView()
			self.view.translatesAutoresizingMaskIntoConstraints = false
			self.view.wantsLayer = true
			//		self.view.layer!.borderWidth = 0.5
			//		self.view.layer!.borderColor = NSColor.systemGray.cgColor
		}

		override func viewDidLoad() {
			super.viewDidLoad()
			if let v = elementView {
				self.view.addSubview(v)
				v.pinEdges(to: self.view)
			}
		}

		var elementView: NSView?
	}
}

// MARK: - Flow layout

// A left-aligned flow layout class
private class CollectionViewLeftAlignedFlowLayout: NSCollectionViewFlowLayout {
	internal var direction: NSUserInterfaceLayoutDirection!

	override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
		let defaultAttributes = super.layoutAttributesForElements(in: rect)
		if defaultAttributes.isEmpty { return defaultAttributes }
		if self.direction == .rightToLeft {
			return self.layoutAttributesForElementsRTL(in: rect, defaultAttributes: defaultAttributes)
		}
		else {
			return self.layoutAttributesForElementsLTR(in: rect, defaultAttributes: defaultAttributes)
		}
	}

	private func layoutAttributesForElementsLTR(
		in rect: NSRect,
		defaultAttributes: [NSCollectionViewLayoutAttributes]
	) -> [NSCollectionViewLayoutAttributes] {
		var attributes = [NSCollectionViewLayoutAttributes]()
		var leftMargin = sectionInset.left
		var lastYPosition = defaultAttributes[0].frame.maxY

		for itemAttributes in defaultAttributes {
			guard let newAttributes = itemAttributes.copy() as? NSCollectionViewLayoutAttributes else {
				continue
			}

			if newAttributes.frame.origin.y > lastYPosition {
				// Wrap to the next line
				leftMargin = sectionInset.left
			}

			newAttributes.frame.origin.x = leftMargin
			leftMargin += newAttributes.frame.width + minimumInteritemSpacing
			lastYPosition = newAttributes.frame.maxY

			attributes.append(newAttributes)
		}
		return attributes
	}

	private func layoutAttributesForElementsRTL(
		in rect: NSRect,
		defaultAttributes: [NSCollectionViewLayoutAttributes]
	) -> [NSCollectionViewLayoutAttributes] {
		var attributes = [NSCollectionViewLayoutAttributes]()
		let rightMargin = self.collectionViewContentSize.width - sectionInset.right
		var rightPosition = rightMargin
		var lastYPosition = defaultAttributes[0].frame.maxY

		for itemAttributes in defaultAttributes {
			guard let newAttributes = itemAttributes.copy() as? NSCollectionViewLayoutAttributes else {
				continue
			}

			if newAttributes.frame.origin.y > lastYPosition {
				// The next line
				rightPosition = rightMargin
			}

			newAttributes.frame.origin.x = rightPosition - itemAttributes.frame.width
			rightPosition -= (newAttributes.frame.width + minimumInteritemSpacing)
			lastYPosition = newAttributes.frame.maxY

			attributes.append(newAttributes)
		}
		return attributes
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *)
struct FlowLayoutPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			Flow(edgeInsets: NSEdgeInsets(edgeInset: 20)) {
				Button(title: "#earth")
				Button(title: "#universe")
				Button(title: "#space")
				Button(title: "#black_hole")
				Button(title: "#meteor")
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
