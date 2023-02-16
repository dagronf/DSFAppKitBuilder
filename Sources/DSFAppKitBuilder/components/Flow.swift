//
//  File.swift
//
//
//  Created by Darren Ford on 15/2/2023.
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
		@ElementBuilder builder: () -> [Element]
	) {
		self.init(
			minimumInteritemSpacing: minimumInteritemSpacing,
			minimumLineSpacing: minimumLineSpacing,
			edgeInsets: edgeInsets,
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
		_ content: [Element]
	) {
		self.elements = content
		self.content = content.compactMap { $0.view() }
		super.init()

		self.collectionView.wantsLayer = true
		self.collectionView.delegate = self
		self.collectionView.dataSource = self

		let layout = CollectionViewLeftAlignedFlowLayout()
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

	// Private
	private let collectionView = FlowCollectionView()
	private let elements: [Element]
	private let content: [NSView]

	override public func view() -> NSView { return self.collectionView }
}

// MARK: - Modifiers

extension Flow: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
	public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		self.content.count
	}

	public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = ElementCollectionItem()
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

// The collection item
private class ElementCollectionItem: NSCollectionViewItem {
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

// MARK: - Flow layout

// A left-aligned flow layout class
private class CollectionViewLeftAlignedFlowLayout: NSCollectionViewFlowLayout {
	override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
		let defaultAttributes = super.layoutAttributesForElements(in: rect)
		if defaultAttributes.isEmpty { return defaultAttributes }

		var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()

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

			leftAlignedAttributes.append(newAttributes)
		}
		return leftAlignedAttributes
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
