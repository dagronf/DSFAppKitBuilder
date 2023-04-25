//
//  NSColor+extensions.swift
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

// MARK: - Animated colors

/// Usage:
///
///   private lazy var textColorAnimator = NSColor.Animator()
///
///   self.textColorAnimator.animate(from: .systemRed, to: .systemBlue, duration: 1.0) { [weak self] color in
///      // Do something with 'color'
///   }


/// A animation handler for NSColor transitions
class NSColorAnimator: NSAnimation {
	var color1: NSColor = .clear
	var color2: NSColor = .clear
	var target: ((NSColor) -> Void)?

	/// Called when the progress is updated
	override public var currentProgress: NSAnimation.Progress {
		get {
			super.currentProgress
		}
		set {
			super.currentProgress = newValue
			let currentColor = self.color1.blended(withFraction: CGFloat(self.currentProgress), of: self.color2) ?? .clear
			self.target?(currentColor)
		}
	}
}

extension NSColor {

	/// An animation class that handles animating between two NSColor objects
	class Animator {
		private let animator = NSColorAnimator()

		/// Start an animation between two colors. If an animation is already running, it will be automatically completed
		/// - Parameters:
		///   - from: Color to start from
		///   - to: Color to end on
		///   - duration: The length (in seconds) of the animation
		///   - progress: The block to call when an intermediate color is presented. Will be called on the main thread.
		func animate(from: NSColor, to: NSColor, duration: Double = 0.2, _ progress: @escaping (NSColor) -> Void) {
			self.animator.stop()
			self.animator.color1 = from
			self.animator.color2 = to
			self.animator.animationBlockingMode = .nonblockingThreaded
			self.animator.duration = duration
			self.animator.target = { color in
				DispatchQueue.main.async {
					progress(color)
				}
			}
			self.animator.start()
		}
	}
}

// MARK: - Color modifications

extension NSColor {
	func flatContrastColor(defaultColor: NSColor = .textColor) -> NSColor {
		if let rgbColor = self.usingColorSpace(.genericRGB),
			rgbColor != NSColor.clear {
			let r = 0.299 * rgbColor.redComponent
			let g = 0.587 * rgbColor.greenComponent
			let b = 0.114 * rgbColor.blueComponent
			let avgGray: CGFloat = 1 - (r + g + b)
			return (avgGray >= 0.45) ? .white : .black
		}
		return defaultColor
	}
}

extension NSColor {
	/// Create an NSColor from an optional CGColor
	@inlinable @inline(__always) static func from(_ color: CGColor?) -> NSColor? {
		using(color) { NSColor(cgColor: $0) } ?? nil
	}
}
