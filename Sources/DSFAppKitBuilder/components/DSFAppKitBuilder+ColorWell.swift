//
//  DSFAppKitBuilder+ColorWell.swift
//
//  Created by Darren Ford on 27/7/21
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

import AppKit.NSColorWell

/// An color view
public class ColorWell: Control {

	public init(
		tag: Int? = nil,
		showsAlpha: Bool = false,
		isBordered: Bool = true,
		color: NSColor? = nil)
	{
		super.init(tag: tag)
		self.colorWell.showsAlpha = showsAlpha
		self.colorWell.isBordered = isBordered

		// Capture changes
		self.colorWell.target = self
		self.colorWell.action = #selector(colorChanged(_:))

		if let c = color {
			self.colorWell.color = c
		}
	}

	// Privates
	private let colorWell = AlphaCompatibleColorWell()
	public override var nsView: NSView { return self.colorWell }

	private lazy var colorBinder = Bindable<NSColor>()
	private var actionCallback: ((NSColor) -> Void)? = nil

	@objc private func colorChanged(_ sender: Any) {
		self.actionCallback?(self.colorWell.color)
	}
}

// MARK: - Action callbacks

public extension ColorWell {
	/// Set a callback block for when the color changes
	func onChange(_ block: @escaping (NSColor) -> Void) -> Self {
		self.actionCallback = block
		return self
	}
}

// MARK: - Bindings

public extension ColorWell {
	/// Bind the image to a keypath
	func bindColor<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSColor>) -> Self {
		self.colorBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.colorWell.color = newValue
		})
		return self
	}
}

// MARK: - Custom Colorwell

internal class AlphaCompatibleColorWell: NSColorWell {
	var showsAlpha: Bool = false
	override func activate(_ exclusive: Bool) {
		NSColorPanel.shared.showsAlpha = self.showsAlpha
		super.activate(exclusive)
	}
}
