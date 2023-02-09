//
//  Shadow.swift
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

import Foundation
import AppKit

/// A shadow definition
public struct Shadow {
	/// The blur radius used to create the shadow
	public let radius: CGFloat
	/// The offset (in points) of the layer’s shadow
	public let offset: CGSize
	/// The color of the layer’s shadow
	public let color: NSColor
	/// The opacity of the layer’s shadow
	public let opacity: CGFloat

	init(
		radius: CGFloat = 3,
		offset: CGSize = CGSize(width: 0, height: -3),
		color: NSColor = .shadowColor,
		opacity: CGFloat = 0.5
	) {
		self.radius = radius
		self.offset = offset
		self.color = color
		self.opacity = opacity
	}
}
