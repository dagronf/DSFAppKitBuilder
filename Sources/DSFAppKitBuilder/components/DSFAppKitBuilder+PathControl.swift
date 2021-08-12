//
//  DSFAppKitBuilder+PathControl.swift
//
//  Created by Darren Ford on 10/8/21
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

import AppKit.NSPathControl

/// An NSPathControl element
public class PathControl: Control {

	/// Create a path control displaying a constant URL value
	public init(url: URL? = nil) {
		super.init()
		self.pathControl.translatesAutoresizingMaskIntoConstraints = false
		self.pathControl.url = url
	}

	/// Create a path control with a binding to a URL
	public init(bindingURL: ValueBinder<URL>) {
		super.init()
		self.pathControl.translatesAutoresizingMaskIntoConstraints = false
		_ = self.bindURL(bindingURL)
	}

	deinit {
		self.fileURLBinder?.detachAll()
	}

	// Private
	private let pathControl = NSPathControl()
	public override func view() -> NSView { return self.pathControl }
	private var actionCallback: ((URL?) -> Void)?

	// Bindables
	private var fileURLBinder: ValueBinder<URL>?

}

// MARK: - Actions

public extension PathControl {
	/// Set a callback block for when the user double-clicks the path control
	func onAction(_ block: @escaping (URL?) -> Void) -> Self {
		self.actionCallback = block
		self.pathControl.target = self
		self.pathControl.doubleAction = #selector(doAction(_:))
		return self
	}

	@objc private func doAction(_ sender: Any) {
		self.actionCallback?(self.pathControl.url)
	}
}

// MARK: - Bindings

public extension PathControl {
	/// Bind to the provided bindable url
	func bindURL(_ fileURL: ValueBinder<URL>) -> Self {
		self.fileURLBinder = fileURL
		fileURL.register(self) { [weak self] newURL in
			self?.pathControl.url = newURL
		}
		return self
	}
}
