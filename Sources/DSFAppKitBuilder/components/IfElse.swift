//
//  OneOf.swift
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
import DSFValueBinders
import Foundation

/// An element that displays a view depending on the condition passed to it
///
/// Example usage:
///
/// ```swift
/// let __condition = ValueBinder(false)
/// ...
///    IfElse(__condition, whenTrue: {
///       Label("Passwords match")
///    }, whenFalse: {
///    Label("Passwords don't match")
///       .textColor(.systemRed)
///    })
/// ```
public class IfElse: OneOf {
	/// Create an IfElse
	/// - Parameters:
	///   - visibleIndexBinder: A binder to the child index that is visible
	public init(
		_ ifTrueBinder: ValueBinder<Bool>,
		whenTrue whenTrueBuilder: () -> Element,
		whenFalse whenFalseBuilder: () -> Element
	) {
		super.init(
			ifTrueBinder.transform { $0 == true ? 0 : 1 },
			builder: {
				whenTrueBuilder()
				whenFalseBuilder()
			}
		)
	}
}
