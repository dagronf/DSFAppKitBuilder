//
//  Element+Panel.swift
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

extension Element {
	/// Attach a panel to the element using a builder to generate the content of the panel
	/// - Parameters:
	///   - title: The panel's title
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - styleMask: The style for the panel
	///   - builder: The builder function for generating the content of the panel
	/// - Returns: self
	@discardableResult public func panel(
		title: String,
		isVisible: ValueBinder<Bool>,
		styleMask: NSWindow.StyleMask = [.titled, .closable, .resizable],
		_ builder: @escaping () -> Element
	) -> Self {
		let panelInstance = PanelInstance(
			title: title,
			isVisible: isVisible,
			styleMask: styleMask,
			builder
		)
		self.attachedObjects.append(panelInstance)
		return self
	}

	/// Attach a panel to the element using a PanelDefinition object
	/// - Parameters:
	///   - panel: The panel definition
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	/// - Returns: self
	@discardableResult public func panel(
		_ panel: PanelDefinition,
		isVisible: ValueBinder<Bool>
	) -> Self {
		panel.setup(isVisible: isVisible)
		return self
	}
}

// MARK: Overridable panel definition

/// A base definition for a Panel
open class PanelDefinition {
	open var title: String { NSLocalizedString("Window", comment: "") }
	/// Override to customize the window's style
	open var styleMask: NSWindow.StyleMask { [.titled, .closable, .resizable] }
	/// The default size for the window
	open var contentRect: NSRect { NSRect(x: 100, y: 100, width: 200, height: 200) }

	/// Create the content to display within the window
	///
	/// You must overload this class and implement `buildContent()` to create the window
	open func buildContent() -> (() -> Element) {
		fatalError("You must overload buildContent in your subclass")
	}

	public init() { }
	deinit {
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("\(self.self): deinit")
		}
	}

	internal func setup(isVisible: ValueBinder<Bool>) {
		self.panelInstance = PanelInstance(
			title: self.title,
  			isVisible: isVisible,
			styleMask: self.styleMask,
  			self.buildContent()
  		)
	}

	private var panelInstance: PanelInstance?
}

/// A panel definition for a simple inspector-style panel
open class InspectorPanelDefinition: PanelDefinition {
	open override var styleMask: NSWindow.StyleMask { [.titled, .closable, .hudWindow, .utilityWindow] }
}

// MARK: Sheet instance wrapper

private class PanelInstance: NSObject {
	init(
		title: String,
		isVisible: ValueBinder<Bool>,
		styleMask: NSWindow.StyleMask,
		_ builder: @escaping () -> Element
	) {
		self.title = title
		self.isVisible = isVisible
		self.styleMask = styleMask
		self.builder = builder

		super.init()

		isVisible.register(self) { [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentPanel()
			}
			else {
				self.dismissPanel()
			}
		}
	}

	deinit {
		self.currentPanel?.close()
		self.builder = nil
		self.isVisible.deregister(self)
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("\(self.self): deinit")
		}
	}

	let isVisible: ValueBinder<Bool>
	let title: String
	let styleMask: NSWindow.StyleMask
	var builder: (() -> Element)?
	var currentPanel: NSPanel?
	let isClosing = ProtectedLock()
}

extension PanelInstance {
	private func presentPanel() {

		if let panel = self.currentPanel {
			panel.makeKeyAndOrderFront(self)
			return
		}

		// Attach the sheet to the window that contains this element
		guard let builder = self.builder else { return }

		let vc = DSFAppKitBuilderAssignableViewController(builder)
		vc.reloadBody()

		let panel = NSPanel(contentViewController: vc)
		panel.title = self.title
		panel.styleMask = self.styleMask
		panel.backingType = .buffered
		panel.level = .floating
		panel.hasShadow = true
		panel.invalidateShadow()

		panel.delegate = self

		panel.makeKeyAndOrderFront(nil)
		self.currentPanel = panel
	}

	private func dismissPanel() {
		if let panel = self.currentPanel {
			isClosing.tryLock {
				panel.close()
			}
		}
		self.currentPanel = nil
		//self.viewController = nil
	}
}

extension PanelInstance: NSWindowDelegate {
	func windowWillClose(_ notification: Notification) {
		isClosing.tryLock {
			self.isVisible.wrappedValue = false
		}
	}
}
