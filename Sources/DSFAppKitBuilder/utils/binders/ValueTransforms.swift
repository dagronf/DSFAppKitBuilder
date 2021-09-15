//
//  ValueTransforms.swift
//
//  Created by Darren Ford on 15/9/21.
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

import Foundation

/// Transform extensions for Bool binding types
public extension ValueBinder where TYPE == Bool {
	/// Returns a new binder for negated the bool value of this binder
	func negated() -> ValueBinder<Bool> {
		let binder = ValueBinder(self.wrappedValue)
		self.register(binder) { newValue in
			binder.wrappedValue = !newValue
		}
		return binder
	}
}

/// Transform extensions for Int binding types
public extension ValueBinder where TYPE == Int {
	/// Returns a new binder to indicate when this binder's value is zero
	func isZero() -> ValueBinder<Bool> {
		let binder = ValueBinder<Bool>(false)
		self.register(binder) { newValue in
			binder.wrappedValue = (newValue == 0)
		}
		return binder
	}

	/// Returns a new binder to indicate when this binder's value is NOT zero
	func isNotZero() -> ValueBinder<Bool> {
		let binder = ValueBinder<Bool>(false)
		self.register(binder) { newValue in
			binder.wrappedValue = (newValue != 0)
		}
		return binder
	}
}

/// Transform extensions for collection types
public extension ValueBinder where TYPE: Collection {
	/// Return a new binder to return true if a collection is empty
	func isEmpty() -> ValueBinder<Bool> {
		let binder = ValueBinder<Bool>(false)
		self.register(binder) { newValue in
			binder.wrappedValue = newValue.isEmpty
		}
		return binder
	}

	/// Return a new binder to return true if a collection is empty
	func isNotEmpty() -> ValueBinder<Bool> {
		let binder = ValueBinder<Bool>(false)
		self.register(binder) { newValue in
			binder.wrappedValue = newValue.isNotEmpty
		}
		return binder
	}
}

/// Transform extensions for collection types
public extension ValueBinder where TYPE == NSSet {
	/// Return a new binder to return true if a collection is empty
	func isEmpty() -> ValueBinder<Bool> {
		let binder = ValueBinder<Bool>(false)
		self.register(binder) { newValue in
			binder.wrappedValue = newValue.isEmpty
		}
		return binder
	}

	/// Return a new binder to return true if a collection is empty
	func isNotEmpty() -> ValueBinder<Bool> {
		let binder = ValueBinder<Bool>(false)
		self.register(binder) { newValue in
			binder.wrappedValue = newValue.isNotEmpty
		}
		return binder
	}
}
