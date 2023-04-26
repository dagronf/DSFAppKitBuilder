//
//  NSGestureRecognizer+extensions.swift
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
import AppKit.NSGestureRecognizer

extension NSGestureRecognizer {
	typealias ACTIONBLOCK = () -> Void

	/// Create an NSButton with a callback block
	convenience init(_ actionBlock: @escaping ACTIONBLOCK) {
		self.init()
		self.actionBlock = actionBlock
	}

	/// The action block associated with the nsbutton
	var actionBlock: ACTIONBLOCK? {
		get {
			objc_getAssociatedObject(self, &Self.objcKey) as? ACTIONBLOCK
		}
		set {
			objc_setAssociatedObject(self, &Self.objcKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
			if let _ = newValue {
				self.target = self
				self.action = #selector(__actionPressed(_:))
			}
			else {
				self.target = nil
				self.action = nil
			}
		}
	}

	// Private
	private static var objcKey = "__gestureblock_0"
}

extension NSGestureRecognizer {
	@objc private func __actionPressed(_ sender: NSButton) {
		self.actionBlock?()
	}
}
