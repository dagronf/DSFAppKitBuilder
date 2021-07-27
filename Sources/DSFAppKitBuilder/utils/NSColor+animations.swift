//
//  NSColor+animations.swift
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

/// Usage:
///
///   private lazy var textColorAnimator = NSColor.Animator()
///
///   self.textColorAnimator.animate(from: .systemRed, to: .systemBlue, duration: 1.0) { [weak self] color in
///      // Do something with 'color'
///   }


#if os(macOS)

import AppKit

class NSColorAnimator: NSAnimation {
	var color1: NSColor = .clear
	var color2: NSColor = .clear
	var target: ((NSColor) -> Void)?
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
	class Animator {
		let animator = NSColorAnimator()
		func animate(from: NSColor, to: NSColor, duration: CGFloat = 0.2, _ progress: @escaping (NSColor) -> Void) {
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

#endif
