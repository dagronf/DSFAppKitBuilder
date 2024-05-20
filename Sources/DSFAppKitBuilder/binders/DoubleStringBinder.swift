//
//  DoubleStringBinder.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
import Foundation

import DSFValueBinders

/// A bindable double <-> string container
public class DoubleStringBinder {
	public let text: ValueBinder<String>
	public let value: ValueBinder<Double>
	public let formatter: NumberFormatter
	private let lock = ProtectedLock()

	public init(initialValue: Double, formatter: NumberFormatter) {
		self.text = ValueBinder<String>("")
		self.value = ValueBinder(initialValue)
		self.formatter = formatter
		self.setup()
	}

	public init(_ value: ValueBinder<Double>, formatter: NumberFormatter) {
		self.text = ValueBinder<String>("")
		self.value = value
		self.formatter = formatter
		self.setup()
	}

	private func setup() {
		self.value.register(self) { [weak self] newDouble in
			guard let `self` = self else { return }
			self.lock.tryLock {
				if let text = self.formatter.string(for: newDouble) {
					self.text.wrappedValue = text
				}
			}
		}

		self.text.register(self) { [weak self] newText in
			guard let `self` = self else { return }
			self.lock.tryLock {
				if let value = self.formatter.number(from: newText)?.doubleValue {
					self.value.wrappedValue = value
				}
			}
		}
	}

	deinit {
		self.text.deregister(self)
		self.value.deregister(self)
	}
}
