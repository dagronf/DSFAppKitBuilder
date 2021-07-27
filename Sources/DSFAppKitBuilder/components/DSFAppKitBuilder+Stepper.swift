//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
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
