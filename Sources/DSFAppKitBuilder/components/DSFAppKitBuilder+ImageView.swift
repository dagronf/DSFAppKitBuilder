//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
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
		_ image: NSImage? = nil)
	{
		super.init(tag: tag)
		if let i = image {
			self.imageView.image = i
		}
		if let f = frameStyle {
			self.imageView.imageFrameStyle = f
		}
	}

	/// The image displayed by the image view.
	public func image(_ image: NSImage) -> Self {
		self.imageView.image = image
		return self
	}

	/// Bind the image to a keypath
	public func bindImage<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSImage>) -> Self {
		self.imageBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.imageView.image = newValue
		})
		return self
	}

	/// The scaling mode applied to make the image fit the frame of the imageview.
	public func scaling(_ scaling: NSImageScaling) -> Self {
		self.imageView.imageScaling = scaling
		return self
	}

	/// The style of the imageView frame
	public func frameStyle(_ frameStyle: NSImageView.FrameStyle) -> Self {
		self.imageView.imageFrameStyle = frameStyle
		return self
	}


	// Privates
	private let imageView = NSImageView()
	public override var nsView: NSView { return self.imageView }
	private lazy var imageBinder = Bindable<NSImage>()
}
