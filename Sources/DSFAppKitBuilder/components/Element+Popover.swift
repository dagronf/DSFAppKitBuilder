//
//  Element+Popover.swift
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

import Foundation
import AppKit.NSView
import DSFValueBinders

// MARK: - Presenting popover

extension Element {
	/// Attach a sheet to this element
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - preferredEdge: The edge of element the popover should prefer to be anchored to.
	///   - builder: A builder for creating the sheet content
	/// - Returns: self
	public func popover(isVisible: ValueBinder<Bool>, preferredEdge: NSRectEdge, _ builder: @escaping () -> Element) -> Self {
		let popoverInstance = PopoverInstance(self, isVisible: isVisible, preferredEdge: preferredEdge, builder)
		attachedObjects.append(popoverInstance)
		return self
	}
}

// MARK: Popover instance wrapper

private class PopoverInstance: NSObject, NSPopoverDelegate {
	init(_ parent: Element, isVisible: ValueBinder<Bool>, preferredEdge: NSRectEdge, _ builder: @escaping () -> Element) {
		self.parent = parent
		self.isVisible = isVisible
		self.viewController = DSFAppKitBuilderAssignableViewController(builder)

		super.init()

		isVisible.register(self) { [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentPopover(self.viewController, isVisible: isVisible, preferredEdge: preferredEdge)
			}
			else {
				self.dismissPopover(self.viewController)
			}
		}
	}

	deinit {
		self.isVisible.deregister(self)
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("\(self.self): deinit")
		}
	}

	private func presentPopover(
		_ viewController: DSFAppKitBuilderAssignableViewController,
		isVisible: ValueBinder<Bool>,
		preferredEdge: NSRectEdge
	) {
		guard let parent = self.parent else { return }
		let popover = NSPopover()
		popover.behavior = .transient
		popover.delegate = self

		viewController.reloadBody()
		popover.contentViewController = viewController
		popover.show(
			relativeTo: parent.view().bounds,
			of: parent.view(),
			preferredEdge: preferredEdge
		)
	}

	public func popoverWillClose(_ notification: Notification) {
		self.isVisible.wrappedValue = false
	}

	private func dismissPopover(_ viewController: DSFAppKitBuilderAssignableViewController) {
		self.viewController.reset()
	}

	weak var parent: Element?
	let viewController: DSFAppKitBuilderAssignableViewController
	let isVisible: ValueBinder<Bool>
}

