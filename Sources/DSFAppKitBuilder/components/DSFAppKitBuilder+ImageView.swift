//
//  DSFAppKitBuilder+ImageView.swift
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

import AppKit.NSImageView

/// An image view
public class ImageView: Control {
	/// Create an Image view
	/// - Parameters:
	///   - tag: (optional) The identifing tag
	///   - frameStyle: The style to use for the frame, or nil for no frame
	///   - image: the image to initially display
	public init(
		tag: Int? = nil,
		frameStyle: NSImageView.FrameStyle? = nil,
		_ image: NSImage? = nil
	) {
		super.init(tag: tag)
		if let i = image {
			self.imageView.image = i
		}
		if let f = frameStyle {
			self.imageView.imageFrameStyle = f
		}
	}

	// Privates
	private let imageView = NSImageView()
	override var nsView: NSView { return self.imageView }
	private lazy var imageBinder = Bindable<NSImage>()
}

// MARK: - Modifiers

public extension ImageView {
	/// The image displayed by the image view.
	func image(_ image: NSImage) -> Self {
		self.imageView.image = image
		return self
	}

	/// The scaling mode applied to make the image fit the frame of the imageview.
	func scaling(_ scaling: NSImageScaling) -> Self {
		self.imageView.imageScaling = scaling
		return self
	}

	/// The style of the imageView frame
	func frameStyle(_ frameStyle: NSImageView.FrameStyle) -> Self {
		self.imageView.imageFrameStyle = frameStyle
		return self
	}
}

// MARK: - Bindings

public extension ImageView {
	/// Bind the image to a keypath
	func bindImage<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSImage>) -> Self {
		self.imageBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.imageView.image = newValue
		})
		self.imageBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}
}
