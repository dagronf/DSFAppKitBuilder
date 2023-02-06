//
//  DSFAppKitBuilder+ElementView.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

import Foundation
import AppKit.NSView
import DSFValueBinders

/// An element that provides a dynamically swappable `Element` via a ValueBinder
///
/// Usage:
///
/// ```swift
/// private let elementBinder = ValueBinder<Element?>(nil)
/// ...
/// ElementView(elementBinder)
/// ```
public class DynamicElement: Element {
	/// Create an ElementView with a hot-swappable Element view
	/// - Parameters:
	///   - element: The ValueBinder<> containing the element to display
	///   - visualEffect: The visual effect to display the content
	public init(_ element: ValueBinder<Element?>, visualEffect: VisualEffect? = nil) {
		self.subElement = element
		if let visualEffect = visualEffect {
			rootView = visualEffect.makeView()
		}
		else {
			rootView = NSView()
		}

		super.init()

		self.rootView.translatesAutoresizingMaskIntoConstraints = false
		self.rootView.setContentHuggingPriority(.init(1), for: .horizontal)
		self.rootView.setContentHuggingPriority(.init(1), for: .vertical)
		self.rootView.setContentCompressionResistancePriority(.init(1), for: .horizontal)
		self.rootView.setContentCompressionResistancePriority(.init(1), for: .vertical)

		element.register(self) { [weak self] newElement in
			self?.updateView(newElement)
		}
	}

	deinit {
		self.subElement?.deregister(self)
		self.subElement = nil
		self.removeChildView()
	}

	private var subElement: ValueBinder<Element?>?
	private let rootView: NSView
	private var currentView: NSView?
	public override func view() -> NSView { self.rootView }
}

private extension DynamicElement {
	func removeChildView() {
		self.currentView?.removeFromSuperview()
		self.currentView = nil
	}

	func updateView(_ newElement: Element?) {
		self.removeChildView()

		if let newElement = newElement {
			let newView = newElement.view()
			self.currentView = newView

			self.rootView.addSubview(newView)
			newView.pinEdges(to: self.rootView)
		}
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)

import DSFMenuBuilder

private let __elementBinder = ValueBinder<Element?>(nil)

import SwiftUI
@available(macOS 10.15, *)
struct DynamicElementPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				PopupButton {
					MenuItem("Text Field")
					MenuItem("Button")
				}
				.onChange { newIndex in
					if newIndex == 1 {
						__elementBinder.wrappedValue = TextField("")
					}
					else if newIndex == 2 {
						__elementBinder.wrappedValue = Button(title: "My button!")
					}
				}
				DynamicElement(__elementBinder)
				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
