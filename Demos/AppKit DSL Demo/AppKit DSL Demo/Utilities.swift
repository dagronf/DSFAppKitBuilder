//
//  utilities.swift
//  utilities
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

extension NSLayoutConstraint.Priority {
	static let stackFiller = NSLayoutConstraint.Priority(100)
}

extension CGFloat {
	static func rand() -> CGFloat {
		CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}

extension NSColor {
	static func randomRGB() -> NSColor {
		NSColor(calibratedRed: CGFloat.rand(), green: CGFloat.rand(), blue: CGFloat.rand(), alpha: 1.0)
	}
}

