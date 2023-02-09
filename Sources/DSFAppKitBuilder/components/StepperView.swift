//
//  Stepper.swift
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

import AppKit.NSStepper
import DSFValueBinders
import DSFStepperView

/// Wrapper for DSFStepperView
///
/// Usage:
///
/// ```swift
///   let valueBinder = ValueBinder(75)
///   ...
///   StepperView(style: .init(numberFormatter: stepperViewFormatter))
///      .bindValue(valueBinder)
///      .bindIsEnabled(enableBinder)
///      .size(width: 120, height: 32)
/// ```
public class StepperView: Element {
	/// The styling for the stepper
	public struct Style {
		/// The font
		public let font: AKBFont?
		/// The text color
		public let textColor: NSColor?
		/// The border color
		public let borderColor: NSColor?
		/// The background color
		public let backgroundColor: NSColor?
		/// The indicator color
		public let indicatorColor: NSColor?
		/// The number formatter used for presenting the value
		public let numberFormatter: NumberFormatter?
		/// Create a style
		public init(
			font: AKBFont? = nil,
			textColor: NSColor? = nil,
			borderColor: NSColor? = nil,
			backgroundColor: NSColor? = nil,
			indicatorColor: NSColor? = nil,
			numberFormatter: NumberFormatter? = nil
		) {
			self.font = font
			self.textColor = textColor
			self.borderColor = borderColor
			self.backgroundColor = backgroundColor
			self.indicatorColor = indicatorColor
			self.numberFormatter = numberFormatter
		}
	}

	/// Create a stepper view
	public init(
		_ initialValue: Double? = 0,
		allowsEmptyValue: Bool = false,
		increment: Double = 1,
		range: ClosedRange<Double> = 0.0 ... 100.0,
		placeholderText: String? = nil,
		allowsKeyboardInput: Bool = false,
		style: Style? = nil
	) {
		super.init()

		self.stepper.allowsEmpty = allowsEmptyValue
		self.stepper.minimum = CGFloat(range.lowerBound)
		self.stepper.maximum = CGFloat(range.upperBound)
		self.stepper.increment = CGFloat(increment)
		self.stepper.allowsKeyboardInput = allowsKeyboardInput

		if let i = initialValue {
			self.stepper.floatValue = CGFloat(i)
		}
		else {
			self.stepper.floatValue = nil
		}

		if let style = style {
			if let f = style.font { self.stepper.font = f.font }
			if let c = style.textColor { self.stepper.foregroundColor = c }
			if let c = style.backgroundColor { self.stepper.borderBackground = c }
			if let c = style.borderColor { self.stepper.borderColor = c }
			if let c = style.indicatorColor { self.stepper.indicatorColor = c }
			if let n = style.numberFormatter { self.stepper.numberFormatter = n }
		}

		if let s = placeholderText {
			self.stepper.placeholder = s
		}

		self.stepper.delegate = self
	}

	deinit {
		self.valueBinder = nil
		self.isEnabledBinder = nil
		self.fontBinder = nil
		self.textColorBinder = nil
		self.backgroundColorBinder = nil
		self.borderColorBinder = nil
		self.indicatorColorBinder = nil
	}

	// private
	private let stepper = DSFStepperView()
	public override func view() -> NSView { return self.stepper }

	// binders
	private var valueBinder: ValueBinder<Double?>?
	private var isEnabledBinder: ValueBinder<Bool>?
	private var fontBinder: ValueBinder<NSFont?>?
	private var textColorBinder: ValueBinder<NSColor?>?
	private var backgroundColorBinder: ValueBinder<NSColor?>?
	private var borderColorBinder: ValueBinder<NSColor?>?
	private var indicatorColorBinder: ValueBinder<NSColor?>?

	// actions
	private var onChangeBlock: ((Double?) -> Void)?
}

// MARK: - Modifiers

public extension StepperView {
	/// Set the placeholder text to be used when there's no value in the control
	func plaeholderText(_ text: String) -> Self {
		self.stepper.placeholder = text
		return self
	}
}


// MARK: - Actions

public extension StepperView {
	/// Set a callback block for when the value changes
	func onChange(_ block: @escaping ((Double?) -> Void)) -> Self {
		self.onChangeBlock = block
		return self
	}
}

// MARK: Bindings

public extension StepperView {
	/// Bind the value of the stepper to a valuebinder
	func bindValue(_ valueBinder: ValueBinder<Double?>) -> Self {
		self.valueBinder = valueBinder
		valueBinder.register { newValue in
			let currentValue: Double? = self.stepper.floatValue == nil ? nil : Double(self.stepper.floatValue!)
			if currentValue != newValue {
				self.stepper.floatValue = newValue == nil ? nil : CGFloat(newValue!)
			}
		}
		return self
	}

	/// Binding for the 'isEnabled' property of the control
	func bindIsEnabled(_ enabledBinding: ValueBinder<Bool>) -> Self {
		enabledBinding.register { [weak self] newValue in
			self?.stepper.isEnabled = newValue
		}
		self.isEnabledBinder = enabledBinding
		return self
	}

	/// Binding for the control's font
	func bindFont(_ fontBinding: ValueBinder<NSFont?>) -> Self {
		fontBinding.register { [weak self] newValue in
			self?.stepper.font = newValue
		}
		self.fontBinder = fontBinding
		return self
	}

	/// Binding for the control's text color
	func bindTextColor(_ binding: ValueBinder<NSColor?>) -> Self {
		binding.register { [weak self] newValue in
			self?.stepper.foregroundColor = newValue
		}
		self.textColorBinder = binding
		return self
	}

	/// Binding for the control's border color
	func bindBorderColor(_ binding: ValueBinder<NSColor?>) -> Self {
		binding.register { [weak self] newValue in
			self?.stepper.borderColor = newValue
		}
		self.borderColorBinder = binding
		return self
	}

	/// Binding for the control's background color
	func bindBackgroundColor(_ binding: ValueBinder<NSColor?>) -> Self {
		binding.register { [weak self] newValue in
			self?.stepper.borderBackground = newValue
		}
		self.backgroundColorBinder = binding
		return self
	}

	/// Binding for the control's indicator color
	func bindIndicatorColor(_ binding: ValueBinder<NSColor?>) -> Self {
		binding.register { [weak self] newValue in
			self?.stepper.indicatorColor = newValue
		}
		self.indicatorColorBinder = binding
		return self
	}
}

extension StepperView: DSFStepperViewDelegateProtocol {
	/// stepperview activity callback
	public func stepperView(_ view: DSFStepperView, didChangeValueTo value: NSNumber?) {
		if self.valueBinder?.wrappedValue != value?.doubleValue {
			self.valueBinder?.wrappedValue = value?.doubleValue
			self.onChangeBlock?(value?.doubleValue)
		}
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
weak var embedded: DSFStepperView?

let value = ValueBinder<Double?>(15.0)
let value2 = ValueBinder<Double?>(nil)
let style2: StepperView.Style = {
	let n = NumberFormatter()
	n.minimumFractionDigits = 1
	n.maximumFractionDigits = 1
	let f = NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
	return StepperView.Style(font: .init(f), numberFormatter: n)
}()

@available(macOS 10.15, *)
struct StepperViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack(spacing: 16, alignment: .leading) {
				VStack(alignment: .leading) {
					Label("Default").font(.title3.bold())
					HStack {
						StepperView(66)
							.size(width: 100, height: 28)
							.bindControl(to: &embedded)
						StepperView(66)
							.bindIsEnabled(.init(false))
							.size(width: 100, height: 28)
						StepperView(66, allowsKeyboardInput: true)
							.size(width: 100, height: 28)
					}
				}
				HDivider()
				VStack(alignment: .leading) {
					Label("Colors").font(.title3.bold())
					HStack {
						StepperView(35, style: .init(textColor: .systemRed, borderColor: .systemRed, backgroundColor: .systemRed.withAlphaComponent(0.1), indicatorColor: .systemRed))
							.size(width: 100, height: 28)
						StepperView(35, style: .init(textColor: .systemGreen, borderColor: .systemGreen, backgroundColor: .systemGreen.withAlphaComponent(0.1), indicatorColor: .systemGreen))
							.size(width: 100, height: 28)
						StepperView(35, style: .init(textColor: .systemBlue, borderColor: .systemBlue, backgroundColor: .systemBlue.withAlphaComponent(0.1), indicatorColor: .systemBlue))
							.size(width: 100, height: 28)
					}
				}
				HDivider()
				VStack(alignment: .leading) {
					Label("Allows empty value (range -10 ... 10, step 0.5)").font(.title3.bold())
					HStack {
						StepperView(nil, allowsEmptyValue: true, increment: 0.5, range: -10 ... 10, allowsKeyboardInput: true, style: style2)
							.plaeholderText("inherited")
							.bindValue(value2)
							.size(width: 120, height: 32)
						StepperView(nil, allowsEmptyValue: true, increment: 0.5, range: -10 ... 10, allowsKeyboardInput: true, style: style2)
							.plaeholderText("inherited")
							.bindValue(value2)
							.bindIsEnabled(.init(false))
							.size(width: 120, height: 32)
					}
				}
				HDivider()
				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
			.frame(width: 400)
		}
	}
}
#endif
