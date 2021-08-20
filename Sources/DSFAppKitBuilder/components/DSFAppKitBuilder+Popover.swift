//
//  DSFAppKitBuilder+Popover.swift
//
//  Created by Darren Ford on 19/8/21
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

import AppKit

/// Create and display a popover containing an Element
///
/// Usage:
///
/// ```swift
/// class MyController: NSObject, DSFAppKitBuilderViewHandler {
///    let popoverLocator = ElementBinder()  // To locate the element anchoring the popup
///
///    // The content of the popover
///    lazy var popover: Popover = Popover {
///       Label("This is the content of the popup")
///    }
///
///    lazy var body: Element =
///       Button("Show Popup") { [weak self] _ in
///          guard let `self` = self,
///                let where = self.popoverLocator.element else {
///              return
///          }
///          self.popover.show(relativeTo: where.bounds,
///                            of: where,
///                            preferredEdge: .maxY)
///       }
///       .bindElement(self.popoverLocator)
/// }
/// ```
public class Popover: NSObject {
	/// Create a popover with an Element as the content
	/// - Parameters:
	///   - behaviour: The popup behaviour
	///   - builder: The builder used when creating the content of the popover
	public init(
		behaviour: NSPopover.Behavior = .transient,
		_ builder: @escaping () -> Element)
	{
		self.behaviour = behaviour
		self.builder = builder
	}

	deinit {
		Logger.Debug("Popover [\(type(of: self))] deinit")
	}

	// Private

	let builder: () -> Element
	let behaviour: NSPopover.Behavior
	var element: Element?
	var popover: NSPopover?
}

public extension Popover {
	/// Shows the popover anchored to the specified element.
	/// - Parameters:
	///   - relativeTo: The rectangle within positioningElement relative to which the popover should be positioned. Normally set to the bounds of positioningView. May be an empty rectangle, which will default to the bounds of positioningView.
	///   - positioningElement: The element to anchor the popover to
	///   - preferredEdge: The edge of positioningElement the popover should prefer to be anchored to.
	func show(
		relativeTo: CGRect,
		of positioningElement: Element,
		preferredEdge: NSRectEdge
	) {
		self.close()

		let controller = NSViewController()

		let popover = NSPopover()
		self.popover = popover

		popover.behavior = .transient
		popover.contentViewController = controller

		// Build the content
		let built = self.builder()
		self.element = built

		let view = built.view()
		controller.view = view

		popover.delegate = self

		popover.show(
			relativeTo: relativeTo,
			of: positioningElement.view(),
			preferredEdge: preferredEdge
		)
	}
}

public extension Popover {
	/// Close the popover
	func close() {
		self.popover?.performClose(self)
	}
}

extension Popover: NSPopoverDelegate {
	public func popoverWillClose(_: Notification) {}

	public func popoverDidClose(_: Notification) {
		self.element = nil
		self.popover = nil
	}
}
