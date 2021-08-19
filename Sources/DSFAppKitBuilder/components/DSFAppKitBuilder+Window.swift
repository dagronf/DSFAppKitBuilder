//
//  DSFAppKitBuilder+Window.swift
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

/// A wrapper for NSWindow
public class Window: NSObject {

	/// Create the window
	public init(title: String,
					styleMask: NSWindow.StyleMask,
					_ builder: @escaping () -> Element) {
		self.title = title
		self.styleMask = styleMask
		self.builder = builder
		super.init()
	}

	deinit {
		self.titleBinder?.deregister(self)
	}

	// private
	var title: String
	let builder: () -> Element

	var content: Element?
	var window: NSWindow?
	var windowController: NSWindowController?
	let styleMask: NSWindow.StyleMask

	private var titleBinder: ValueBinder<String>?
}

public extension Window {
	/// Present the window
	func present(contentRect: NSRect) {
		guard self.window == nil else {
			self.window?.makeKeyAndOrderFront(self)
			return
		}

		let window = NSWindow(
			contentRect: contentRect,
			styleMask: self.styleMask,
			backing: .buffered,
			defer: true
		)
		window.isReleasedWhenClosed = true

		self.window = window

		let content = self.builder()
		self.content = content

		let controller = WindowController(window: window)

		window.title = title
		window.contentView = content.view()
		window.autorecalculatesKeyViewLoop = true

		self.windowController = controller
		controller.setupWindowListener { [weak self] in
			self?.windowClosed()
		}

		window.makeKeyAndOrderFront(self)
		window.recalculateKeyViewLoop()
	}

	func windowClosed() {
		self.content = nil
		self.window = nil
		self.windowController = nil
	}
}

public extension Window {
	/// Bind the title to a text ValueBinder
	/// - Parameters:
	///   - textValue: The value binding for the title of the window
	/// - Returns: Self
	func bindTitle(_ textValue: ValueBinder<String>) -> Self {
		self.titleBinder = textValue
		textValue.register(self) { [weak self] newValue in
			self?.window?.title = newValue
		}
		return self
	}
}

private class WindowController: NSWindowController {
	func setupWindowListener(_ completion: @escaping () -> Void) {
		NotificationCenter.default.addObserver(
			forName: NSWindow.willCloseNotification,
			object: self.window,
			queue: .main
		) { _ in
			completion()
		}
	}
}

