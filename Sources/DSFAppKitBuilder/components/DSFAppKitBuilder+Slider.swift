//
//  DSFAppKitBuilder+Slider.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
import DSFValueBinders

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
	/// Create a slider element
	/// - Parameters:
	///   - range: The range of the slider
	///   - value: The initial value for the slider
	///   - isVertical: A bool indicating the orientation (horizontal or vertical) of the slider.
	public init(
		range: ClosedRange<Double> = 0 ... 100,
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
		self.valueBinder?.deregister(self)
		self.actionCallback = nil
	}

	// Private
	private let slider = NSSlider()
	override public func view() -> NSView { return self.slider }
	private var valueBinder: ValueBinder<Double>?
	private var actionCallback: ((Double) -> Void)?
}

// MARK: - Modifiers

public extension Slider {
	/// The number of tick marks associated with the slider.
	func numberOfTickMarks(_ count: Int, allowsTickMarkValuesOnly: Bool = false) -> Self {
		self.slider.numberOfTickMarks = count
		self.slider.allowsTickMarkValuesOnly = allowsTickMarkValuesOnly
		return self
	}

	/// The color of the filled portion of the slider track, in appearances that support it.
	func trackColor(_ color: NSColor) -> Self {
		self.slider.trackFillColor = color
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
		valueBinder.register { [weak self] newValue in
			self?.slider.doubleValue = newValue
		}
		return self
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

private let _value1 = ValueBinder(40.0)
private let _value2 = ValueBinder(86.0)
private let _value3 = ValueBinder(10.0)
private let _numberFormatter: NumberFormatter = {
	let n = NumberFormatter()
	n.maximumFractionDigits = 2
	n.minimumFractionDigits = 2
	return n
}()

@available(macOS 10.15, *)
struct SliderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				Grid {
					GridRow {
						Label("continuous (regular)")
						Slider(range: 0 ... 100, value: 10)
							.bindValue(_value1)
						Label(_value1.stringValue())
							.formatter(_numberFormatter)
							.width(50)
					}
					GridRow {
						Label("continuous (small)")
						Slider(range: 0 ... 100, value: 10)
							.bindValue(_value1)
							.controlSize(.small)
							.trackColor(.systemRed)
						Label(_value1.stringValue())
							.formatter(_numberFormatter)
							.width(50)
					}
					GridRow {
						Label("continuous (mini)")
						Slider(range: 0 ... 100, value: 10)
							.bindValue(_value1)
							.controlSize(.mini)
							.trackColor(.systemPurple)
						Label(_value1.stringValue())
							.formatter(_numberFormatter)
							.width(50)
					}
					GridRow {
						Label("show tick marks")
						Slider(range: 0 ... 100, value: 10)
							.bindValue(_value2)
							.numberOfTickMarks(10)
						Label(_value2.stringValue())
							.formatter(_numberFormatter)
							.width(50)
					}
					GridRow {
						Label("stop on tick marks")
						Slider(range: 0 ... 100, value: 10)
							.bindValue(_value3)
							.numberOfTickMarks(11, allowsTickMarkValuesOnly: true)
						Label(_value3.stringValue())
							.formatter(_numberFormatter)
							.width(50)
					}
				}
				.columnFormatting(xPlacement: .trailing, atColumn: 0)
				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
