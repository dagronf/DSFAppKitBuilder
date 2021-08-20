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
///
/// Usage:
///
/// ```swift
/// class MyController: NSObject, DSFAppKitBuilderViewHandler {
///    lazy var myWindow: Window = Window(
///       title: "My Window",
///       styleMask: [.titled, .closable, .miniaturizable, .resizable], /*.fullSizeContentView])*/
///       frameAutosaveName: "My-Window-frame")
///    {
///       Label("Label in a window")
///    }
///
///    lazy var body: Element =
///       VStack {
///          Button("Open Window") { [weak self] _ in
///             self?.myWindow.show(contentRect: ...)
///          }
///       }
///    }
/// }
/// ```
public class Window: NSObject {

	/// The contained NSWindow object
	public private(set) var window: NSWindow?

	/// Create the window
	/// - Parameters:
	///   - title: The title to display for the window
	///   - styleMask: The window’s style
	///   - isMovableByWindowBackground: A Boolean value that indicates whether the window is movable by clicking and dragging anywhere in its background.
	///   - frameAutosaveName: Sets the name AppKit uses to automatically save the window’s frame rectangle data in the defaults system.
	///   - builder: The builder used when creating the content of the popover
	public init(
		title: String,
		styleMask: NSWindow.StyleMask,
		isMovableByWindowBackground: Bool = false,
		frameAutosaveName: NSWindow.FrameAutosaveName? = nil,
		_ builder: @escaping () -> Element
	) {
		self.title = title
		self.styleMask = styleMask
		self.isMovableByWindowBackground = isMovableByWindowBackground
		self.frameAutosaveName = frameAutosaveName
		self.builder = builder
		super.init()
	}

	deinit {
		self.titleBinder?.deregister(self)
		self.onWindowCreate = nil
		self.onWindowClose = nil
	}

	// private
	var title: String
	let builder: () -> Element

	var content: Element?
	var windowController: NSWindowController?
	let styleMask: NSWindow.StyleMask
	let isMovableByWindowBackground: Bool
	let frameAutosaveName: NSWindow.FrameAutosaveName?

	private var titleBinder: ValueBinder<String>?

	private var onWindowCreate: ((NSWindow) -> Void)?
	private var onWindowClose: ((NSWindow) -> Void)?
}

public extension Window {
	/// Present the window
	/// - Parameters:
	///   - contentRect: The initial rect for the window on the current screen
	///   - useSavedPosition: If true, tries to use a previously saved position for restoring the view.
	func show(contentRect: NSRect,
				 useSavedPosition: Bool = true) {
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
		self.window = window

		window.title = self.title
		window.isReleasedWhenClosed = true
		window.isMovableByWindowBackground = self.isMovableByWindowBackground
		window.autorecalculatesKeyViewLoop = true

		self.setInitialWindowPosition(useSavedPosition: useSavedPosition)

		let content = self.builder()
		self.content = content

		let controller = WindowController(window: window)
		window.contentView = content.view()
		window.contentView?.needsLayout = true
		window.contentView?.needsDisplay = true

		self.windowController = controller
		controller.setupWindowListener { [weak self] in
			self?.windowWillClose()
		}

		window.makeKeyAndOrderFront(self)
		window.recalculateKeyViewLoop()

		/// Call the callback if it has been set
		self.onWindowCreate?(window)
	}
}

// MARK: - Functions

public extension Window {
	/// Minimise a window to the dock
	@inlinable func minimise() {
		self.window?.miniaturize(self)
	}

	/// Deminiaturize a window from the dock
	@inlinable func deminiaturize() {
		self.window?.deminiaturize(self)
	}

	/// Simulates the user clicking the zoom box by momentarily highlighting the button and then zooming the window.
	@inlinable func zoom() {
		self.window?.performZoom(self)
	}

	/// Make the window the key window
	@inlinable func makeKey(andOrderFront orderFront: Bool = false) {
		if orderFront {
			self.window?.makeKeyAndOrderFront(self)
		}
		else {
			self.window?.makeKey()
		}
	}

	/// Close the window if it is open
	func close() {
		self.window?.performClose(self)
	}
}

// MARK: - Actions

public extension Window {

	/// Block to call when the window is first displayed
	func onOpen(_ block: @escaping (NSWindow) -> Void) -> Self {
		self.onWindowCreate = block
		return self
	}

	/// Block to call when the window is going to close
	func onClose(_ block: @escaping (NSWindow) -> Void) -> Self {
		self.onWindowClose = block
		return self
	}
}

// MARK: - Bindings

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

// MARK: - Window positioning

private extension Window {
	func setInitialWindowPosition(useSavedPosition: Bool) {
		self.frameAutosaveName.withUnwrapped { value in
			if useSavedPosition {
				self.window?.setFrameUsingName(value)
			}
			self.window?.setFrameAutosaveName(value)
		}
	}

	func saveLastWindowPosition() {
		if let f = self.frameAutosaveName, let w = self.window {
			w.saveFrame(usingName: f)
		}
	}
}

// MARK: - Window close handling

private extension Window {
	func windowWillClose() {
		self.saveLastWindowPosition()

		if let w = self.window {
			self.onWindowClose?(w)
		}

		self.content = nil
		self.window = nil
		self.windowController = nil
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
