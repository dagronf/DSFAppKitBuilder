//
//  NumberField.swift
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

/// A text field optimized for displaying and editing number values
public class NumberField: TextField {
	/// Create a number field that displays and edits an integer value, formatted using the supplied formatter
	public init(_ numberBinder: ValueBinder<Int>, numberFormatter: NumberFormatter = NumberFormatter()) {
		self.intBinder = numberBinder
		self.formatter = numberFormatter

		super.init()

		self.label.formatter = self.formatter
		self.label.stringValue = self.formatter.string(from: NSNumber(value: numberBinder.wrappedValue)) ?? ""

		numberBinder.register(self) { [weak self] newValue in
			guard let `self` = self else { return }
			self.label.stringValue = self.formatter.string(from: NSNumber(value: newValue)) ?? ""
		}
	}

	/// Create a number field that displays and edits a double value, formatted using the supplied formatter
	public init(_ numberBinder: ValueBinder<Double>, numberFormatter: NumberFormatter = NumberFormatter()) {
		self.doubleBinder = numberBinder
		self.formatter = numberFormatter

		super.init()

		self.label.formatter = self.formatter
		self.label.stringValue = self.formatter.string(from: NSNumber(value: numberBinder.wrappedValue)) ?? ""

		numberBinder.register(self) { [weak self] newValue in
			guard let `self` = self else { return }
			self.label.stringValue = self.formatter.string(from: NSNumber(value: newValue)) ?? ""
		}
	}

	override public func textDidChange() {
		super.textDidChange()

		self.intBinder?.wrappedValue = (self.formatter.number(from: self.label.stringValue) ?? 0).intValue
		self.doubleBinder?.wrappedValue = (self.formatter.number(from: self.label.stringValue) ?? 0).doubleValue
	}

	deinit {
		self.intBinder?.deregister(self)
		self.doubleBinder?.deregister(self)
	}

	private var intBinder: ValueBinder<Int>?
	private var doubleBinder: ValueBinder<Double>?
	private let formatter: NumberFormatter
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI

private let _value1 = ValueBinder(1)
private let _value2 = ValueBinder(24.55)
private let _formatter = NumberFormatter {
	$0.minimumFractionDigits = 1
	$0.maximumFractionDigits = 4
}

@available(macOS 10.15, *)
struct NumberFieldPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				Grid {
					GridRow(rowAlignment: .lastBaseline) {
						Label("Default")
						NumberField(_value1)
					}
					GridRow(rowAlignment: .lastBaseline) {
						Label("Integer only")
						NumberField(_value2, numberFormatter: _formatter)
					}
				}
				EmptyView()
			}
			.SwiftUIPreview()
		}
	}
}
#endif
