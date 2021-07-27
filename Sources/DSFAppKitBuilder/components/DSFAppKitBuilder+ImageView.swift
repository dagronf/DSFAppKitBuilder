//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSImageView

public class ImageView: Control {
	let imageView = NSImageView()
	public override var nsView: NSView { return self.imageView }

	public init(tag: Int? = nil,
					_ image: NSImage? = nil)
	{
		super.init(tag: tag)
		if let i = image {
			self.imageView.image = i
		}
	}

	public func image(_ image: NSImage) -> Self {
		self.imageView.image = image
		return self
	}

	private lazy var imageBinder = Bindable<NSImage>()
	public func bindImage<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSImage>) -> Self {
		self.imageBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.imageView.image = newValue
		})
		return self
	}

	public func scaling(_ scaling: NSImageScaling) -> Self {
		self.imageView.imageScaling = scaling
		return self
	}

	public func dimension(_ size: CGSize, h: NSLayoutConstraint.Priority? = nil, v: NSLayoutConstraint.Priority? = nil) -> Self {
		let h1 = NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: size.width)
		if	let h = h { h1.priority = h }
		self.imageView.addConstraint(h1)

		let v1 = NSLayoutConstraint(item: self.imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: size.height)
		if	let v = v { v1.priority = v }
		self.imageView.addConstraint(v1)
		return self
	}
}
