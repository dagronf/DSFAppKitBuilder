//
//  BindingsBag.swift
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
import DSFValueBinders

internal class BindingsBag {

	private class Item {
		weak var object: AnyObject?
		let binding: ValueBinderRegistrable
		init(_ object: AnyObject? = nil, _ binding: ValueBinderRegistrable) {
			self.object = object
			self.binding = binding
		}

		deinit {
			if let o = self.object {
				self.binding.deregister(o)
			}
		}
	}

	private var items: [Item] = []

	/// Add a binding to the bag
	func append(_ object: AnyObject?, _ binding: ValueBinderRegistrable) {
		self.items.append(Item(object, binding))
	}

	func deregisterAll() {
		self.items.removeAll()
	}

	deinit {
		self.deregisterAll()
	}
}
