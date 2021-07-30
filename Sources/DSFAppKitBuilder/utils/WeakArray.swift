//
//  File.swift
//  File
//
//  Created by Darren Ford on 30/7/21.
//

import Foundation

final class WeakBox<A: AnyObject> {
	weak var unbox: A?
	init(_ value: A) {
		unbox = value
	}
}

struct WeakArray<Element: AnyObject> {
	private var items: [WeakBox<Element>] = []
	init() {
	}
	init(_ elements: [Element]) {
		items = elements.map { WeakBox($0) }
	}
}

extension WeakArray: Collection {
	var startIndex: Int { return items.startIndex }
	var endIndex: Int { return items.endIndex }
	
	subscript(_ index: Int) -> Element? {
		return items[index].unbox
	}
	
	func index(after idx: Int) -> Int {
		return items.index(after: idx)
	}
}
