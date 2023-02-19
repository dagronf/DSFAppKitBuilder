//
//  Window.swift
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

/// A wrapper for NSWindow
///
/// Usage:
///
/// ```swift
/// class MyController: NSObject, DSFAppKitBuilderViewHandler {
///    var currentWindow: Window?
///    func createWindow() -> Window {
///       return Window(
///          title: "My Window",
///          contentRect: NSRect(x: 100, y: 100, width: 200, height: 200)
///          styleMask: [.titled, .closable, .miniaturizable, .resizable],
///          frameAutosaveName: "My.Window.Frame")
///       {
///          Label("Label in a window")
///       }
///       .onClose { [weak self] _ in
///          self?.currentWindow = nil
///       }
///
///       lazy var body: Element =
///          VStack {
///             Button("Open Window") { [weak self] _ in
///                self?.currentWindow = self?.createWindow()
///             }
///          }
///       }
///    }
/// }
/// ```
public class Window: NSObject {
	/// The available toolbar styles
	public enum ToolbarStyle: Int {
		 case automatic = 0
		 case expanded = 1
		 case preference = 2
		 case unified = 3
		 case unifiedCompact = 4
	}

	public typealias CompletionBlock = (() -> Void)

	/// The contained NSWindow object
	public private(set) var window: NSWindow?

	/// Create the window
	/// - Parameters:
	///   - title: The title to display for the window
	///   - contentRect: The initial rect for the window on the current screen
	///   - styleMask: The window’s style
	///   - isMovableByWindowBackground: A Boolean value that indicates whether the window is movable by clicking and dragging anywhere in its background.
	///   - frameAutosaveName: Sets the name AppKit uses to automatically save the window’s frame rectangle data in the defaults system.
	///   - useSavedPosition: If true, tries to use a previously saved position for restoring the view.
	///   - builder: The builder used when creating the content of the popover
	convenience public init(
		title: String,
		contentRect: NSRect,
		styleMask: NSWindow.StyleMask,
		isMovableByWindowBackground: Bool = false,
		frameAutosaveName: NSWindow.FrameAutosaveName? = nil,
		useSavedPosition: Bool = true,
		_ builder: () -> Element
	) {
		self.init(title: title,
					 contentRect: contentRect,
					 styleMask: styleMask,
					 isMovableByWindowBackground: isMovableByWindowBackground,
					 frameAutosaveName: frameAutosaveName,
					 useSavedPosition: useSavedPosition,
					 presentOnScreen: true,
					 builder)
	}

	/// Create the window
	/// - Parameters:
	///   - title: The title to display for the window
	///   - contentRect: The initial rect for the window on the current screen
	///   - styleMask: The window’s style
	///   - isMovableByWindowBackground: A Boolean value that indicates whether the window is movable by clicking and dragging anywhere in its background.
	///   - frameAutosaveName: Sets the name AppKit uses to automatically save the window’s frame rectangle data in the defaults system.
	///   - useSavedPosition: If true, tries to use a previously saved position for restoring the view.
	///   - builder: The builder used when creating the content of the popover
	internal init(
		title: String,
		contentRect: NSRect,
		styleMask: NSWindow.StyleMask,
		isMovableByWindowBackground: Bool = false,
		frameAutosaveName: NSWindow.FrameAutosaveName? = nil,
		useSavedPosition: Bool = true,
		presentOnScreen: Bool = true,
		_ builder: () -> Element
	) {
		self.title = title
		self.styleMask = styleMask
		self.isMovableByWindowBackground = isMovableByWindowBackground
		self.frameAutosaveName = frameAutosaveName
		super.init()

		let content = builder()
		self.content = content

		self.show(contentRect: contentRect, useSavedPosition: useSavedPosition, presentOnScreen: presentOnScreen)
	}

	deinit {
		Logger.Debug("Window[\(type(of: self))] deinit")
		self.titleBinder?.deregister(self)
		self.onWindowClose = nil
	}

	// private
	private var title: String
	private var content: Element?
	private var windowController: NSWindowController?
	private let styleMask: NSWindow.StyleMask
	private let isMovableByWindowBackground: Bool
	private let frameAutosaveName: NSWindow.FrameAutosaveName?
	private var toolbarStyle: Window.ToolbarStyle?
	private var titleBinder: ValueBinder<String>?

	private var onWindowClose: ((Window) -> Void)?

	internal var onWindowMiniaturize: ((Bool) -> Void)?
}

public extension Window {
	override var debugDescription: String {
		return "[Window: \(self.title)]"
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

// MARK: - Modifiers

public extension Window {
	/// Set the style for the toolbar
	@discardableResult func toolbarStyle(_ style: ToolbarStyle?) -> Self {
		self.toolbarStyle = style
		return self
	}
}

// MARK: - Actions

public extension Window {
	/// Block to call when the window is going to close
	func onClose(_ block: @escaping (Window) -> Void) -> Self {
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
		textValue.register { [weak self] newValue in
			self?.window?.title = newValue
		}
		return self
	}

	/// Bind this element to an ElementBinder
	func bindWindow(_ windowBinder: WindowBinder) -> Self {
		windowBinder.window = self
		return self
	}
}

internal extension Window {

	/// Present the window
	/// - Parameters:
	///   - contentRect: The initial rect for the window on the current screen
	///   - useSavedPosition: If true, tries to use a previously saved position for restoring the view.
	///   - presentOnScreen: If true, present the window on screen.  If false, create the window but don't display it
	func show(contentRect: NSRect,
				 useSavedPosition: Bool,
				 presentOnScreen: Bool)
	{
		guard let content = self.content else {
			fatalError()
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

		let controller = WindowController(window: window)
		window.contentView = content.view()
		window.contentView?.needsLayout = true
		window.contentView?.needsDisplay = true

		self.windowController = controller
		controller.setupWindowListener { [weak self] in
			self?.windowWillClose()
		}

		window.recalculateKeyViewLoop()

		if #available(macOS 11.0, *) {
			if let toolbarStyle = self.toolbarStyle {
				self.window?.toolbarStyle = NSWindow.ToolbarStyle(rawValue: toolbarStyle.rawValue)!
			}
		}

		if presentOnScreen {
			window.makeKeyAndOrderFront(self)
		}

		window.delegate = self
	}
}

extension Window: NSWindowDelegate {
	public func windowDidMiniaturize(_ notification: Notification) {
		self.onWindowMiniaturize?(true)
	}

	public func windowDidDeminiaturize(_ notification: Notification) {
		self.onWindowMiniaturize?(false)
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

extension Window {
	func windowWillClose() {
		self.saveLastWindowPosition()

		self.onWindowClose?(self)

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
