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

public class Stepper: Control {
	let stepper = NSStepper()
	public override var nsView: NSView { return self.stepper }

	public init(
		tag: Int? = nil,
		range: ClosedRange<Double> = 0...100,
		increment: Double = 1,
		value: Double = 20
	) {
		super.init(tag: tag)

		self.stepper.minValue = range.lowerBound
		self.stepper.maxValue = range.upperBound
		self.stepper.increment = increment
		self.stepper.doubleValue = value

		self.stepper.target = self
		self.stepper.action = #selector(stepperDidChange(_:))
	}

	@objc private func stepperDidChange(_ sender: Any) {
		valueBinder.setValue(self.stepper.doubleValue)
		if valueBinder.isActive {
			valueBinder.setValue(self.stepper.doubleValue)
		}
	}

	private lazy var valueBinder = Bindable<Double>()
	public func bindValue<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Double>) -> Self {
		self.valueBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.stepper.doubleValue = newValue
		})
		self.valueBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}
}
