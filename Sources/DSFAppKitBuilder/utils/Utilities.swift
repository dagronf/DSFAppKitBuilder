//
//  Utilities.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

public extension NSView {
	func pinEdges(to other: NSView, offset: CGFloat = 0, animate: Bool = false) {
		let target = animate ? animator() : self
		target.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: offset).isActive = true
		target.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: offset).isActive = true
		target.topAnchor.constraint(equalTo: other.topAnchor, constant: offset).isActive = true
		target.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: offset).isActive = true
	}
}

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
		func animate(from: NSColor, to: NSColor, _ progress: @escaping (NSColor) -> Void) {
			self.animator.stop()
			self.animator.color1 = from
			self.animator.color2 = to
			self.animator.animationBlockingMode = .nonblockingThreaded
			self.animator.duration = 0.25
			self.animator.target = { color in
				DispatchQueue.main.async {
					progress(color)
				}
			}
			self.animator.start()
		}
	}
}
