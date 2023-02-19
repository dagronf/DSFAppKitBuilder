//
//  ProtectedLock.swift
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

/// A simple thread-safe lock
class ProtectedLock {
	/// Perform 'block' after acquiring the lock
	func whileLocked(_ block: () -> Void) {
		self.lock.wait()
		defer { self.lock.signal() }
		block()
	}

	/// Perform 'block' if the lock can be aquired.
	///
	/// By default if the lock cannot be acquired the call returns immediately
	@discardableResult func tryLock(timeout: DispatchTime = .now(), _ block: () -> Void) -> Bool {
		if self.lock.wait(timeout: timeout) != .timedOut {
			defer { self.lock.signal() }
			block()
			return true
		}
		return false
	}
	private let lock = DispatchSemaphore(value: 1)
}
