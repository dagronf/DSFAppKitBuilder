//
//  Shape.swift
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

public class Shape: Element {
	let path: CGPath
	public init(path: CGPath) {
		self.path = path
		self.content.path = path
		super.init()
	}

	override public func view() -> NSView { return self.content }
	private let content = ShapeView()
}

public extension Shape {
	/// The fill color
	@discardableResult func fillColor(_ color: CGColor, _ fillRule: CAShapeLayerFillRule = .nonZero) -> Self {
		self.content.shape.fillColor = color
		self.content.shape.fillRule = fillRule
		return self
	}

	/// The stroke color
	@discardableResult func strokeColor(_ color: CGColor) -> Self {
		self.content.shape.strokeColor = color
		return self
	}

	/// The line width
	@discardableResult func lineWidth(_ width: CGFloat) -> Self {
		self.content.shape.lineWidth = width
		return self
	}

	/// A drop shadow for the path
	@discardableResult override func shadow(
		radius: CGFloat = 3,
		offset: CGSize = CGSize(width: 0, height: -3),
		color: NSColor = .shadowColor,
		opacity: CGFloat = 0.5
	) -> Self {
		self.content.layer?.masksToBounds = false
		using(self.content.shape) {
			$0.shadowRadius = radius
			$0.shadowOffset = offset
			$0.shadowColor = color.cgColor
			$0.shadowOpacity = Float(opacity)
			$0.masksToBounds = false
		}
		return self
	}
}

public extension Shape {
	/// Fallback 'all formatting' access
	func format(_ formatBlock: (CAShapeLayer) -> Void) -> Self {
		formatBlock(self.content.shape)
		return self
	}
}

private extension Shape {
	class ShapeView: NSView {
		let shape = CAShapeLayer()
		var path: CGPath? {
			didSet {
				self.shape.path = self.path
			}
		}

		init() {
			super.init(frame: .zero)
			self.translatesAutoresizingMaskIntoConstraints = false
			self.wantsLayer = true
			self.layer!.addSublayer(self.shape)
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func layout() {
			super.layout()
			self.shape.frame = self.bounds
		}
	}
}
