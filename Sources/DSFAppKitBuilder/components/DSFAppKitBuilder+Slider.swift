//
//  DSFAppKitBuilder+Slider.swift
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

import AppKit.NSSlider

public class Slider: Control {
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

	// Private
	private let slider = NSSlider()
	override var nsView: NSView { return self.slider }
	private lazy var valueBinder = Bindable<Double>()
	private var actionCallback: ((Double) -> Void)? = nil
}

// MARK: - Modifiers

public extension Slider {
	func numberOfTickMarks(_ count: Int, allowsTickMarkValuesOnly: Bool = false) -> Self {
		self.slider.numberOfTickMarks = count
		self.slider.allowsTickMarkValuesOnly = allowsTickMarkValuesOnly
		return self
	}
}

// MARK: - Actions

public extension Slider {

	/// Set a callback block for when the selection changes
	func onChange(_ block: @escaping (Double) -> Void) -> Self {
		self.actionCallback = block
		return self
	}

	@objc private func sliderDidChange(_ sender: Any) {
		valueBinder.setValue(self.slider.doubleValue)
	}
}

// MARK: - Bindings

public extension Slider {
	/// Bind the value for the slider to a key path
	func bindValue<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Double>) -> Self {
		self.valueBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.slider.doubleValue = newValue
		})
		self.valueBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}
}
