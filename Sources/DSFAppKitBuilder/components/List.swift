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

/// A 'list' style element which builds its content from an array of elements and dynamically
/// updates its content as the array of elements change
///
/// ```swift
/// let items = ValueBinder([0,1,2,3,4,5,6,7,8,9])
/// …
/// List(self.items) { [weak self] item in
///    HStack {
///       Text("Item \(item)")
///       Button(...)
///    }
/// }
/// ```
/// Note the use of `[weak self]` in the initial `List` block - it's important that the self is held weakly
/// throughout the list builder block.
public class List<ListItem>: Element {
	/// Creates a list element from a binding
	/// - Parameters:
	///   - spacing: The spacing to use between list elements
	///   - useAlternatingRowBackground: If true, alternates the background color of each row
	///   - elements: The elements to bind to the list
	///   - listItemContent: The builder function operating on each item in the list to build its display element
	public init(
		spacing: CGFloat? = nil,
		useAlternatingRowBackground: Bool = true,
		_ elements: ValueBinder<[ListItem]>,
		_ listItemContent: @escaping (ListItem) -> Element
	) {
		self.useAlternatingRowBackground = useAlternatingRowBackground
		self.elements = elements
		self.mapFunc = listItemContent

		super.init()

		if let spacing = spacing { self.spacing(spacing) }

		elements.register { [weak self] newValue in
			DispatchQueue.main.async {
				self?.updateItems()
			}
		}
	}

	/// Create a list element from a static (non-changing) array of items
	/// - Parameters:
	///   - spacing: The spacing to use between list elements
	///   - useAlternatingRowBackground: If true, alternates the background color of each row
	///   - elements: The elements to bind to the list
	///   - listItemContent: The builder function operating on each item in the list to build its display element
	public init(
		spacing: CGFloat? = nil,
		useAlternatingRowBackground: Bool = true,
		_ elements: [ListItem],
		_ listItemContent: @escaping (ListItem) -> Element
	) {
		self.useAlternatingRowBackground = useAlternatingRowBackground
		self.mapFunc = listItemContent
		self.elements = ValueBinder(elements)
		super.init()

		if let spacing = spacing { self.spacing(spacing) }
		DispatchQueue.main.async { [weak self] in
			self?.updateItems()
		}
	}

	private let mapFunc: (ListItem) -> Element
	private let elements: ValueBinder<[ListItem]>

	public override func view() -> NSView { return self.stack }
	private let stack: NSStackView = {
		let v = NSStackView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.orientation = .vertical
		v.alignment = .width
		v.setHuggingPriority(.init(10), for: .horizontal)
		v.setContentHuggingPriority(.init(10), for: .horizontal)
		return v
	}()
	private let useAlternatingRowBackground: Bool
	private var alternatingColors: (NSColor, NSColor)?
	private var currentElements: [Element] = []
}

public extension List {
	/// The inset for the list
	@discardableResult func edgeInsets(_ edgeInsets: NSEdgeInsets) -> Self {
		self.stack.edgeInsets = edgeInsets
		return self
	}

	@discardableResult func edgeInsets(_ edgeInset: CGFloat) -> Self {
		self.stack.edgeInsets = NSEdgeInsets(edgeInset: edgeInset)
		return self
	}

	/// The minimum spacing, in points, between adjacent views in the list.
	@discardableResult func spacing(_ spacing: CGFloat) -> Self {
		self.stack.spacing = spacing
		return self
	}

	/// The view alignment within the list.
	@discardableResult func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
		self.stack.alignment = alignment
		return self
	}

	/// The colors to use when drawing the row backgrounds
	@discardableResult func rowColors(_ c0: NSColor, _ c1: NSColor) -> Self {
		self.alternatingColors = (c0, c1)
		return self
	}
}

private extension List {
	func updateItems() {
		assert(Thread.isMainThread)
		self.removeAllItems()
		let content = self.elements.wrappedValue

		self.view().usingEffectiveAppearance {

			var rowState = false

			content.forEach { item in
				// Generate the display element for the item
				let element = self.mapFunc(item)

				if self.useAlternatingRowBackground {
					if let alternatingColors = alternatingColors {
						element.backgroundColor(rowState ? alternatingColors.0 : alternatingColors.1)
					}
					else {
						if #available(macOS 10.14, *) {
							element.backgroundColor(.alternatingContentBackgroundColors[rowState ? 0 : 1])
						} else {
							element.backgroundColor(.controlAlternatingRowBackgroundColors[rowState ? 0 : 1])
						}
					}
				}

				let v = element.view()
				if !(v is NothingView) {
					stack.addArrangedSubview(v)
					self.currentElements.append(element)
					rowState.toggle()
				}
			}
		}
	}

	func removeAllItems() {
		self.stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
		self.currentElements = []
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import DSFMenuBuilder
import SwiftUI

private let __debugItems = ValueBinder([0,1,2,3,4,5,6,7,8,9])

@available(macOS 10.15, *)
struct ListPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				DSFAppKitBuilder.List(__debugItems) { item in
					Label("Noodle \(item)")
				}
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
