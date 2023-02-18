//
//  ManagedWindow.swift
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
import AppKit

import DSFValueBinders

/// A managed window
open class ManagedWindow: NSObject {
	/// Create a managed window
	/// - Parameter isVisible: A value binder to show or close the window
	public init(
		isVisible: ValueBinder<Bool>
	) {
		self.isVisible = isVisible

		super.init()

		isVisible.register(self) { [weak self] newState in
			guard let `self` = self else { return }
			if newState {
				self.present()
			}
			else {
				if !self.isClosing {
					self.isClosing = true
					self.currentWindow?.window?.close()
					self.isClosing = false
				}
			}
		}
	}

	/// Override to customize the title of the window
	open var title: String { NSLocalizedString("Window", comment: "") }
	/// Override to customize the window's style
	open var styleMask: NSWindow.StyleMask { [.titled, .closable, .miniaturizable, .resizable] }
	/// Override to allow the user to drag the window by dragging its background
	open var isMovableByWindowBackground: Bool { false }
	/// Provide a name with which to save the window's position and size
	open var frameAutosaveName: NSWindow.FrameAutosaveName? { nil }
	/// The default size for the window
	open var contentRect: NSRect { NSRect(x: 100, y: 100, width: 200, height: 200) }

	/// Create the content to display within the window
	///
	/// You must overload this class and implement `buildContent()` to create the window
	open func buildContent() -> Element {
		fatalError("You must overload buildContent in your subclass")
	}

	deinit {
		self.openBlock = nil
		self.closeBlock = nil
		self.isVisible.deregister(self)
		self.titleBinder?.deregister(self)
		self.close()
	}

	// Private

	private let isVisible: ValueBinder<Bool>
	private var currentWindow: DSFAppKitBuilder.Window?
	private var isClosing: Bool = false
	private var toolbarStyle: Window.ToolbarStyle?

	private var titleBinder: ValueBinder<String>?
	private var openBlock: ((Window) -> Void)?
	private var closeBlock: ((Window) -> Void)?
}

private extension ManagedWindow {

	private func present() {
		if self.currentWindow != nil {
			self.makeKey()
			return
		}
		self.currentWindow = Window(
			title: self.title,
			contentRect: self.contentRect,
			styleMask: self.styleMask,
			isMovableByWindowBackground: self.isMovableByWindowBackground,
			frameAutosaveName: self.frameAutosaveName,
			{ self.buildContent() }
		)
		.onClose { [weak self] window in
			guard let `self` = self else { return }
			if !self.isClosing {
				self.isClosing = true
				self.isVisible.wrappedValue = false
				self.isClosing = false
			}
			if let window = self.currentWindow {
				self.closeBlock?(window)
			}
			self.currentWindow = nil
		}

		if let binder = self.titleBinder {
			self.currentWindow?.window?.title = binder.wrappedValue
		}

		if let window = self.currentWindow {
			self.openBlock?(window)
			window.toolbarStyle(self.toolbarStyle)
		}
	}

	private func makeKey() {
		self.currentWindow?.window?.makeKeyAndOrderFront(self)
	}

	private func close() {
		if let window = self.currentWindow {
			window.window?.close()
			self.closeBlock?(window)
		}
	}
}

public extension ManagedWindow {
	/// Set the style of the toolbar (only effective macOS 11+)
	@discardableResult func toolbarStyle(_ style: Window.ToolbarStyle) -> Self {
		self.toolbarStyle = style
		return self
	}
}


// MARK: - Callbacks

public extension ManagedWindow {
	@discardableResult func onOpen(_ block: @escaping (Window) -> Void) -> Self {
		self.openBlock = block
		return self
	}
	@discardableResult func onClose(_ block: @escaping (Window) -> Void) -> Self {
		self.closeBlock = block
		return self
	}
}

// MARK: - Binder

public extension ManagedWindow {
	@discardableResult func bindTitle(_ binder: ValueBinder<String>) -> Self {
		self.titleBinder = binder
		binder.register(self) { [weak self] newTitle in
			self?.currentWindow?.window?.title = newTitle
		}
		return self
	}
}
