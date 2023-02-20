//
//  PathControl.swift
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

import AppKit.NSPathControl
import DSFValueBinders

/// An NSPathControl element
///
/// Usage:
///
/// ```swift
/// let urlBinder = ValueBinder<URL>(…some url…)
/// …
/// PathControl(bindingURL: urlBinder)
/// ```
public class PathControl: Control {
	/// Create a path control displaying a constant URL value
	public init(
		url: URL? = nil,
		style: NSPathControl.Style = .standard
	) {
		super.init()
		self.setup()
		self.pathControl.pathStyle = style
		self.pathControl.url = url
	}

	/// Create a path control with a binding to a URL
	public init(
		bindingURL: ValueBinder<URL>,
		style: NSPathControl.Style = .standard
	) {
		super.init()
		self.setup()
		self.pathControl.pathStyle = style
		_ = self.bindURL(bindingURL)
	}

	deinit {
		self.fileURLBinder?.deregister(self)
		self.actionCallback = nil
		self.doubleActionCallback = nil
		self.pathItemClicked = nil
	}

	// Private
	private let pathControl = NSPathControl()
	override public func view() -> NSView { return self.pathControl }
	private var actionCallback: ((URL?) -> Void)?
	private var doubleActionCallback: ((URL?) -> Void)?
	private var pathItemClicked: ((NSPathControlItem) -> Void)?

	// Bindables
	private var fileURLBinder: ValueBinder<URL>?
}

private extension PathControl {
	private func setup() {
		self.pathControl.target = self
		self.pathControl.action = #selector(doAction(_:))
		self.pathControl.doubleAction = #selector(doDoubleAction(_:))
	}
	
	// Callback when the user single-clicks the path control
	@objc private func doAction(_ sender: Any) {
		self.actionCallback?(self.pathControl.url)
		if let which = self.pathControl.clickedPathItem {
			self.pathItemClicked?(which)
		}
	}

	// Callback when the user double-clicks the path control
	@objc private func doDoubleAction(_ sender: Any) {
		self.doubleActionCallback?(self.pathControl.url)
	}
}

// MARK: - Actions

public extension PathControl {
	/// Set a callback block for when the user single-clicks the path control
	func onAction(_ block: @escaping (URL?) -> Void) -> Self {
		self.actionCallback = block
		return self
	}

	/// Set a callback block for when the user double-clicks the path control
	func onDoubleAction(_ block: @escaping (URL?) -> Void) -> Self {
		self.doubleActionCallback = block
		return self
	}

	/// Set a block to be called when a user selects a path item in the control
	func onClickPathComponent(_ block: @escaping (NSPathControlItem) -> Void) -> Self {
		self.pathItemClicked = block
		return self
	}
}

// MARK: - Bindings

public extension PathControl {
	/// Bind to the provided bindable url
	func bindURL(_ fileURL: ValueBinder<URL>) -> Self {
		self.fileURLBinder = fileURL
		fileURL.register { [weak self] newURL in
			self?.pathControl.url = newURL
		}
		return self
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

fileprivate func __getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths.first!
}

@available(macOS 10.15, *)
struct PathPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				Grid {
					GridRow(rowAlignment: .lastBaseline) {
						Label("Home:").font(.headline)
						PathControl(url: FileManager.default.homeDirectoryForCurrentUser)
							.horizontalCompressionResistancePriority(.defaultLow)
					}
					GridRow(rowAlignment: .lastBaseline) {
						Label("Documents:").font(.headline)
						PathControl(url: __getDocumentsDirectory())
							.horizontalCompressionResistancePriority(.defaultLow)
					}
					GridRow(rowAlignment: .lastBaseline) {
						Label("Documents (disabled):").font(.headline)
						PathControl(url: __getDocumentsDirectory())
							.horizontalCompressionResistancePriority(.defaultLow)
							.isEnabled(false)
					}
					GridRow(rowAlignment: .lastBaseline) {
						Label("Temporary:").font(.headline)
						PathControl(url: FileManager.default.temporaryDirectory)
							.horizontalCompressionResistancePriority(.defaultLow)
					}
				}
				.columnFormatting(xPlacement: .trailing, atColumn: 0)
				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
