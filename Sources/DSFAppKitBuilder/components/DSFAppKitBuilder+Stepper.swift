//
//  DSFAppKitBuilder+Stepper.swift
//
//  Created by Darren Ford on 27/7/21
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

import AppKit.NSStepper

/// Wrapper for NSStepper
///
/// Usage:
///
/// ```swift
/// Stepper(range: 0 ... 100, value: 20)
///    .bindValue(self.stepperValue)
/// ```
public class Stepper: Control {

	/// Create a stepper element
	/// - Parameters:
	///   - range: The range of values
	///   - increment: The amount by which the receiver changes with each increment or decrement.
	///   - value: The initial value for the stepper
	public init(
		range: ClosedRange<Double> = 0...100,
		increment: Double = 1,
		value: Double = 20
	) {
		super.init()

		self.stepper.minValue = range.lowerBound
		self.stepper.maxValue = range.upperBound
		self.stepper.increment = increment
		self.stepper.doubleValue = value

		self.stepper.target = self
		self.stepper.action = #selector(stepperDidChange(_:))
	}

	deinit {
		self.valueBinder?.detachAll()
	}

	// Private
	private let stepper = NSStepper()
	public override func view() -> NSView { return self.stepper }
	private var valueBinder: ValueBinder<Double>?
	private var actionCallback: ((Double) -> Void)? = nil
}

// MARK: - Actions

public extension Stepper {
	/// Set a callback block for when the selection changes
	func onChange(_ block: @escaping (Double) -> Void) -> Self {
		self.actionCallback = block
		return self
	}

	@objc private func stepperDidChange(_ sender: Any) {
		let newValue = self.stepper.doubleValue

		// Call the callback if it is set
		self.actionCallback?(newValue)

		// Tell the binder to update
		self.valueBinder?.wrappedValue = self.stepper.doubleValue
	}
}

// MARK: - Bindings

public extension Stepper {

	/// Bind the stepper value
	func bindValue(_ value: ValueBinder<Double>) -> Self {
		self.valueBinder = value
		value.register(self) { [weak self] newValue in
			self?.stepper.doubleValue = newValue
		}

		return self
	}
}
