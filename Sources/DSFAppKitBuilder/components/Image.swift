//
//  Image.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
import CoreGraphics
import AppKit

import DSFValueBinders

/// A simple image element
///
/// Setting the size of the image
///
/// You can fix the size of the image by using a `.size()` modifier,
/// or you can specify a `scale` parameter to fix a size based on the size of the image
/// eg. `.scale(2)` will generate a retina-scaled version of the image
public class Image: Element {
	/// The image to display
	public var image: CGImage? {
		didSet {
			self.reflectUpdatedImage()
		}
	}

	/// The scale for the resulting image
	public var scale: CGFloat? {
		didSet {
			self.reflectUpdatedImage()
		}
	}

	/// Create an Image
	/// - Parameter cgImage: The image to display
	/// - Parameter scale: The scale for the resulting image, or nil for unscaled
	public init(_ cgImage: CGImage?, scale: CGFloat? = nil) {
		self.image = cgImage
		self.scale = scale
		super.init()
		self.reflectUpdatedImage()
	}

	/// Create an Image
	/// - Parameter cgImage: The image to display
	/// - Parameter scale: The scale for the resulting image, or nil for unscaled
	public init(_ nsImage: NSImage, scale: CGFloat? = nil) {
		self.image = nsImage.cgImage()
		self.scale = scale
		super.init()
		self.reflectUpdatedImage()
	}

	deinit {
		self.imageBinder?.deregister(self)
	}

	public override func view() -> NSView { self.contentView }

	private let contentView: NSView = {
		let v = NSView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.wantsLayer = true
		return v
	}()

	private var widthConstraint: NSLayoutConstraint?
	private var heightConstraint: NSLayoutConstraint?

	private var imageBinder: ValueBinder<CGImage?>?
}

public extension Image {
	/// If true, hug the element size to the pixel size of the image
	func scale(_ value: CGFloat) -> Self {
		self.scale = value
		return self
	}
}

public extension Image {
	/// Bind a CGImage to this element
	/// - Parameter imageBinder: The image binding
	/// - Returns:
	func bindImage(_ imageBinder: ValueBinder<CGImage?>) -> Self {
		self.imageBinder = imageBinder
		imageBinder.register { [weak self] newValue in
			self?.image = newValue
		}
		return self
	}

	/// Bind an `NSImage` to this element
	/// - Parameter imageBinder: The image binding
	/// - Returns:
	func bindImage(_ imageBinder: ValueBinder<NSImage?>) -> Self {
		self.imageBinder = imageBinder.transform { $0?.cgImage() }
		imageBinder.register { [weak self] newValue in
			self?.image = newValue?.cgImage()
		}
		return self
	}
}

private extension Image {
	func removeWidthHeightConstraints() {
		if let widthConstraint = widthConstraint {
			self.contentView.removeConstraint(widthConstraint)
			self.widthConstraint = nil
		}
		if let heightConstraint = heightConstraint {
			self.contentView.removeConstraint(heightConstraint)
			self.heightConstraint = nil
		}
		self.contentView.needsUpdateConstraints = true
	}

	func reflectUpdatedImage() {
		// Set the image
		self.contentView.layer!.contents = image

		// Remove any existing height and width constraints
		self.removeWidthHeightConstraints()

		if let image = image,
			let scale = self.scale
		{
			let w = CGFloat(image.width)
			let wc = NSLayoutConstraint(
				item: self.contentView, attribute: .width,
				relatedBy: .equal,
				toItem: nil, attribute: .notAnAttribute,
				multiplier: 1, constant: w / scale
			)
			wc.priority = .defaultHigh
			self.widthConstraint = wc
			self.contentView.addConstraint(wc)

			let h = CGFloat(image.height)
			let hc = NSLayoutConstraint(
				item: self.contentView, attribute: .height,
				relatedBy: .equal,
				toItem: nil, attribute: .notAnAttribute,
				multiplier: 1, constant: h / scale
			)
			hc.priority = .defaultHigh
			self.heightConstraint = hc
			self.contentView.addConstraint(hc)

			self.contentView.needsUpdateConstraints = true
		}
	}
}
