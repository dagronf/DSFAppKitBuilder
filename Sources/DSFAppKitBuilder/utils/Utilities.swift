//
//  Utilities.swift
//
//  Created by Darren Ford on 10/8/21
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

/// Perform an immediate `transform` of a given `subject`. The `transform`
/// function may just mutate the given `subject`, or replace it entirely.
///
/// ```
/// let oneAndTwo = mutate([1]) {
///     $0.append(2)
/// }
/// ```
///
/// - Parameters:
///     - subject: The subject to transform.
///     - transform: The transformation to perform.
///
/// - Throws: Any error that was thrown inside `transform`.
///
/// - Returns: A transformed `subject`.
@discardableResult
@inlinable internal func with<T>(_ subject: T, _ transform: (_ subject: inout T) throws -> Void) rethrows -> T {
	var subject = subject
	try transform(&subject)
	return subject
}

@discardableResult
@inlinable func using<T, R>(_ value: T?, _ block: (T) -> R) -> R? {
	if let value = value {
		return block(value)
	}
	return nil
}

extension Optional {
	/// Perform a block ONLY if we can be unwrapped
	/// - Parameter block: The block to be called with the unwrapped element
	@inlinable func withUnwrapped(_ block: (Wrapped) throws -> Void) rethrows {
		if let value = self {
			try block(value)
		}
	}
}

extension Optional where Wrapped: Collection {
	/// Returns true if the optional is empty AND the wrapped collection is also empty
	@inlinable var isNilOrEmpty: Bool {
		return self?.isEmpty ?? true
	}
}

extension NSEdgeInsets {
	@inlinable public init(edgeInset: CGFloat) {
		self.init(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
	}
}

extension Collection {
	@inlinable public var isNotEmpty: Bool {
		return !self.isEmpty
	}
}

extension NSSet {
	@inlinable var isEmpty: Bool { return self.count == 0 }
	@inlinable var isNotEmpty: Bool { return self.count > 0 }
}
