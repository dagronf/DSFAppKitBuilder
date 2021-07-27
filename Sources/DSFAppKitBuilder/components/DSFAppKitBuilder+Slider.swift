//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSSlider

public class Slider: Control {
	let slider = NSSlider()
	public override var nsView: NSView { return self.slider }

	public init(
		tag: Int? = nil,
		range: ClosedRange<Double> = 0...100,
		value: Double = 20,
		isVertical: Bool = false
	) {
		super.init(tag: tag)

		self.slider.minValue = range.lowerBound
		self.slider.maxValue = range.upperBound
		self.slider.doubleValue = value

		self.slider.target = self
		self.slider.action = #selector(sliderDidChange(_:))
		self.slider.isVertical = isVertical
	}

	@objc private func sliderDidChange(_ sender: Any) {
		valueBinder.setValue(self.slider.doubleValue)
	}

	private lazy var valueBinder = Bindable<Double>()
	public func bindValue<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Double>) -> Self {
		self.valueBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.slider.doubleValue = newValue
		})
		self.valueBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	public func numberOfTickMarks(_ count: Int, allowsTickMarkValuesOnly: Bool = false) -> Self {
		self.slider.numberOfTickMarks = count
		self.slider.allowsTickMarkValuesOnly = allowsTickMarkValuesOnly
		return self
	}
}
