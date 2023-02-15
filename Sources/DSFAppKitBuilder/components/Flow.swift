//
//  File.swift
//  
//
//  Created by Darren Ford on 15/2/2023.
//

import Foundation
import AppKit


public class Flow: Element {

	convenience public init(
		minimumInteritemSpacing: CGFloat? = nil,
		minimumLineSpacing: CGFloat? = nil,
		@ElementBuilder builder: () -> [Element]) {
		self.init(
			minimumInteritemSpacing: minimumInteritemSpacing,
			minimumLineSpacing: minimumLineSpacing,
			content: builder()
		)
	}

	public init(
		minimumInteritemSpacing: CGFloat? = nil,
		minimumLineSpacing: CGFloat? = nil,
		content: [Element]
	) {
		self.content = content.compactMap { $0.view() }
		super.init()

		self.collectionView.setContentHuggingPriority(.init(10), for: .horizontal)
		self.collectionView.setContentHuggingPriority(.init(999), for: .vertical)

		self.collectionView.delegate = self
		self.collectionView.dataSource = self

		let layout = CollectionViewLeftFlowLayout()
		if let minimumInteritemSpacing = minimumInteritemSpacing {
			layout.minimumInteritemSpacing = minimumInteritemSpacing
		}
		if let minimumLineSpacing = minimumLineSpacing {
			layout.minimumLineSpacing = minimumLineSpacing
		}
		self.collectionView.collectionViewLayout = layout

		self.collectionView.reloadData()
	}

	// Private

	private let collectionView = NSCollectionView()
	private let content: [NSView]

	public override func view() -> NSView { return self.collectionView }
}

class ElementCollectionItem: NSCollectionViewItem {

	override func loadView() {
		self.view = NSView()
		self.view.translatesAutoresizingMaskIntoConstraints = false
		self.view.wantsLayer = true
		self.view.layer!.borderWidth = 0.5
		self.view.layer!.borderColor = NSColor.systemGray.cgColor
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if let v = elementView {
			self.view.addSubview(v)
			v.pinEdges(to: self.view, edgeInset: 2)
		}
	}
	var elementView: NSView?
}

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


// MARK: - Flow layout

class CollectionViewLeftFlowLayout: NSCollectionViewFlowLayout {

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

			if newAttributes.frame.origin.y > lastYPosition { // NewLine
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
