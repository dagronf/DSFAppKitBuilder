//
//  Window+Sheet.swift
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

import AppKit

/// A sheet
public class Sheet: Window {
	public typealias ReturnType = NSApplication.ModalResponse
	public typealias CompletionBlock = ((Sheet.ReturnType) -> Void)

	public convenience init(
		title: String,
		contentRect: NSRect,
		styleMask: NSWindow.StyleMask,
		frameAutosaveName: NSWindow.FrameAutosaveName? = nil,
		useSavedPosition: Bool = true,
		_ builder: () -> Element
	) {
		self.init(
			title: title,
			contentRect: contentRect,
			styleMask: styleMask,
			isMovableByWindowBackground: false,
			frameAutosaveName: frameAutosaveName,
			useSavedPosition: useSavedPosition,
			presentOnScreen: false,
			builder
		)
	}

	internal weak var parent: Window?
	internal var completion: CompletionBlock?
}

// MARK: - Present/Dismiss

public extension Sheet {
	/// Dismiss the sheet if it is currently displaying
	func dismiss(result: Sheet.ReturnType) {
		if let parent = self.parent?.window,
			let sheetWindow = self.window
		{
			parent.endSheet(sheetWindow, returnCode: result)
			self.close()
			self.windowWillClose()
			self.completion?(result)
		}

		self.parent = nil
		self.completion = nil
	}
}

// MARK: - Bindings

public extension Sheet {
	/// Bind this element to an ElementBinder
	func bindSheet(_ sheetBinder: SheetBinder) -> Self {
		sheetBinder.sheet = self
		return self
	}
}
