//
//  List.swift
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
import DSFValueBinders

public class List<ListItem>: Element {
	public init(
		_ elements: ValueBinder<[ListItem]>,
		_ listItemContent: @escaping (ListItem) -> Element)
	{
		self.elements = elements
		self.mapFunc = listItemContent

		super.init()

		elements.register { [weak self] newValue in
			DispatchQueue.main.async {
				self?.updateItems()
			}
		}
	}

	private let mapFunc: (ListItem) -> Element
	private let elements: ValueBinder<[ListItem]>

	public override func view() -> NSView { return self.stack }
	private let stack: NSStackView = {
		let v = NSStackView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.orientation = .vertical
		v.alignment = .leading
		return v
	}()
	private var currentElements: [Element] = []
}

extension List {
	/// The inset for the list
	func edgeInsets(_ edgeInsets: NSEdgeInsets) -> Self {
		self.stack.edgeInsets = edgeInsets
		return self
	}

	/// The minimum spacing, in points, between adjacent views in the list.
	func spacing(_ spacing: CGFloat) -> Self {
		self.stack.spacing = spacing
		return self
	}

	/// The view alignment within the list.
	func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
		self.stack.alignment = alignment
		return self
	}
}

extension List {
	func updateItems() {
		assert(Thread.isMainThread)
		self.removeAllItems()
		let content = self.elements.wrappedValue
		content.forEach { item in
			let element = self.mapFunc(item)
			let v = element.view()
			if !(v is NothingView) {
				stack.addArrangedSubview(v)
				self.currentElements.append(element)
			}
		}
	}

	private func removeAllItems() {
		self.stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.currentElements = []
	}
}


// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import DSFMenuBuilder
import SwiftUI

let items = ValueBinder([0,1,2,3,4,5,6,7,8,9])

@available(macOS 10.15, *)
struct ListPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				DSFAppKitBuilder.List(items) { item in
					Label("Noodle \(item)")
				}
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
