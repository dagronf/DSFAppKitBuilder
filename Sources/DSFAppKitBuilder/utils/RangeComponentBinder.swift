//
//  RangeComponentBinder.swift
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

import DSFValueBinders
import Foundation

/// A convenience for two-way binding with the range and components of an NSRange.
/// Changing any component automatically reflects the changes in the other components
public class RangeComponentBinders {
	/// Create
	public init() {}

	/// Location binder
	public var location: ValueBinder<Int> { return self._location }
	/// Length binder
	public var length: ValueBinder<Int> { return self._length }
	/// Range binder
	public var range: ValueBinder<NSRange> { return self._range }

	// Private

	private var isUpdating = false
	private lazy var _location = ValueBinder<Int>(0) { [weak self] newValue in
		self?.reflectLocationChanges()
	}

	private lazy var _length = ValueBinder<Int>(0) { [weak self] newValue in
		self?.reflectLengthChanges()
	}

	private lazy var _range = ValueBinder<NSRange>(NSRange()) { [weak self] newValue in
		self?.reflectRangeChange()
	}
}

private extension RangeComponentBinders {
	private func safeUpdate(_ block: () -> Void) {
		if !self.isUpdating {
			self.isUpdating = true
			block()
			self.isUpdating = false
		}
	}

	private func reflectLocationChanges() {
		self.safeUpdate { _range.wrappedValue.location = self._location.wrappedValue }
	}

	private func reflectLengthChanges() {
		self.safeUpdate { _range.wrappedValue.length = self._length.wrappedValue }
	}

	private func reflectRangeChange() {
		self.safeUpdate {
			let newLocation = _range.wrappedValue.location
			let newLength = _range.wrappedValue.length

			if _location.wrappedValue != newLocation {
				_location.wrappedValue = newLocation
			}
			if _length.wrappedValue != newLength {
				_length.wrappedValue = newLength
			}
		}
	}
}
