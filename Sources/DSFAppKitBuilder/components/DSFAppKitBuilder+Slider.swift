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

/// A slider control
///
/// Usage:
///
/// ```swift
/// Slider(range: 0 ... 100, value: 10)
///    .bindIsEnabled(self.switchOn)
///    .bindValue(self.sliderValue)
/// ```
public class Slider: Control {
	/// Createa slider element
	/// - Parameters:
	///   - range: The range of the slider
	///   - value: The initial value for the slider
	///   - isVertical: A bool indicating the orientation (horizontal or vertical) of the slider.
	public init(
		range: ClosedRange<Double> = 0...100,
		value: Double = 20,
		isVertical: Bool = false
	) {
		super.init()

		self.slider.minValue = range.lowerBound
		self.slider.maxValue = range.upperBound
		self.slider.doubleValue = value

		self.slider.target = self
		self.slider.action = #selector(sliderDidChange(_:))
		self.slider.isVertical = isVertical
	}

	deinit {
		self.valueBinder?.detachAll()
	}

	// Private
	private let slider = NSSlider()
	public override func view() -> NSView { return self.slider }
	private var valueBinder: ValueBinder<Double>?
	private var actionCallback: ((Double) -> Void)? = nil
}

// MARK: - Modifiers

public extension Slider {
	/// The number of tick marks associated with the slider.
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
		let newValue = self.slider.doubleValue

		// Call the callback if it is set
		self.actionCallback?(newValue)

		// Tell the binder to update
		self.valueBinder?.wrappedValue = self.slider.doubleValue
	}
}

// MARK: - Bindings

public extension Slider {
	/// Bind the value for the slider to a key path
	func bindValue(_ valueBinder: ValueBinder<Double>) -> Self {
		self.valueBinder = valueBinder
		valueBinder.register(self) { [weak self] newValue in
			self?.slider.doubleValue = newValue
		}
		return self
	}
}
