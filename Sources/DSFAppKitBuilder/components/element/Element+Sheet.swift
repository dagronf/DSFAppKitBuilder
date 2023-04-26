//
//  Element+Sheet.swift
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

// MARK: - Presenting sheet

extension Element {
	/// Attach a sheet using a SheetDefinition object
	/// - Parameters:
	///   - sheet: The sheet definition
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	/// - Returns: self
	@discardableResult public func sheet(
		_ sheet: SheetDefinition,
		isVisible: ValueBinder<Bool>
	) -> Self {
		sheet.setup(parent: self, isVisible: isVisible)
		return self
	}

	/// Attach a sheet to this element
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - styleMask: The stylemask to apply to the sheet window
	///   - frameAutosaveName: The name AppKit uses to automatically save the window’s frame rectangle data in the defaults system.
	///   - builder: A builder for creating the sheet content
	/// - Returns: self
	public func sheet(
		isVisible: ValueBinder<Bool>,
		styleMask: NSWindow.StyleMask = [.resizable],
		frameAutosaveName: NSWindow.FrameAutosaveName? = nil,
		_ builder: @escaping () -> Element
	) -> Self {
		let sheetInstance = SheetInstance(
			parent: self,
			isVisible: isVisible,
			styleMask: styleMask,
			frameAutosaveName: frameAutosaveName,
			builder
		)
		self.attachedObjects.append(sheetInstance)
		return self
	}
}

// MARK: Overridable sheet definition

/// A base definition for a sheet.
open class SheetDefinition {
	open var title: String { NSLocalizedString("sheet", comment: "") }
	/// Override to customize the window's style
	open var styleMask: NSWindow.StyleMask { [.resizable] }
	/// The default (initial) size for the window
	open var contentRect: NSRect { NSRect(x: 0, y: 0, width: 200, height: 200) }
	/// The name AppKit uses to automatically save the window’s frame rectangle data in the defaults system.
	open var frameAutosaveName: NSWindow.FrameAutosaveName? { nil }

	/// Create the content to display within the sheet window
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

	/// Call to dismiss the sheet. If the sheet is not visible, does nothing
	public func dismiss() {
		if let binder = self.isVisibleBinder, binder.wrappedValue == true {
			binder.wrappedValue = false
		}
	}

	// Private

	private var isVisibleBinder: ValueBinder<Bool>?
	private var sheetInstance: SheetInstance?
}

extension SheetDefinition {
	internal func setup(parent: Element, isVisible: ValueBinder<Bool>) {
		self.isVisibleBinder = isVisible

		self.sheetInstance = SheetInstance(
			parent: parent,
			isVisible: isVisible,
			styleMask: self.styleMask,
			frameAutosaveName: self.frameAutosaveName,
			self.buildContent()
		)
	}
}


// MARK: Sheet instance wrapper

private class SheetInstance: NSObject, NSWindowDelegate {
	init(
		parent: Element,
		isVisible: ValueBinder<Bool>,
		styleMask: NSWindow.StyleMask,
		frameAutosaveName: NSWindow.FrameAutosaveName?,
		_ builder: @escaping () -> Element
	) {
		self.parent = parent
		self.styleMask = styleMask
		self.frameAutosaveName = frameAutosaveName
		self.viewController = DSFAppKitBuilderAssignableViewController(builder)
		self.isVisible = isVisible

		super.init()

		isVisible.register(self) { [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentSheet()
			}
			else {
				self.dismissSheet()
			}
		}
	}

	deinit {
		self.isVisible.deregister(self)
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("\(self.self): deinit")
		}
	}

	private func presentSheet() {
		// Attach the sheet to the window that contains this element
		guard let parentWindow = self.parent?.view().window else { return }

		let window = KeyableWindow(
			contentRect: .zero,
			styleMask: self.styleMask,
			backing: .buffered,
			defer: true
		)

		window.title = "sheet"
		window.isReleasedWhenClosed = true
		window.isMovableByWindowBackground = false
		window.autorecalculatesKeyViewLoop = true
		window.delegate = self

		if let saveName = self.frameAutosaveName {
			window.setFrameAutosaveName(saveName)
		}

		let content = NSView()
		content.autoresizingMask = [.width, .height]

		viewController.reloadBody()
		content.addSubview(viewController.view)
		viewController.view.pinEdges(to: content)

		window.contentView = content

		window.recalculateKeyViewLoop()

		parentWindow.beginSheet(window)
	}

	private func dismissSheet() {
		guard
			let parentWindow = self.parent?.view().window,
			let sheetWindow = self.viewController.view.window
		else {
			return
		}
		parentWindow.endSheet(sheetWindow)

		viewController.reset()
	}

	func windowWillClose(_ notification: Notification) {
		if
			let f = self.frameAutosaveName,
			let sheetWindow = self.viewController.view.window
		{
			sheetWindow.saveFrame(usingName: f)
		}
	}

	weak var parent: Element?
	let viewController: DSFAppKitBuilderAssignableViewController
	let isVisible: ValueBinder<Bool>
	let styleMask: NSWindow.StyleMask
	let frameAutosaveName: NSWindow.FrameAutosaveName?

	class KeyableWindow: NSWindow {
		override var canBecomeKey: Bool { true }
	}
}
