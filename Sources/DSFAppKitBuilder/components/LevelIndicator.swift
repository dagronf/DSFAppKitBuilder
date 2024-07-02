//
//  LevelIndicator.swift
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

import AppKit.NSStepper
import DSFValueBinders

/// Wrapper for NSLevelIndicator
///
/// Usage:
///
/// ```swift
/// Stepper(range: 0 ... 100, value: 20)
///    .bindValue(self.stepperValue)
/// ```
public class LevelIndicator: Control {
	/// Create a level indicator
	/// - Parameters:
	///   - style: The indicator style
	///   - initialValue: The initial value for the stepper
	///   - range: The range of values
	public convenience init(
		style: NSLevelIndicator.Style,
		initialValue value: Double = 20,
		range: ClosedRange<Double> = 0 ... 100
	) {
		self.init()

		self.levelIndicator.levelIndicatorStyle = style
		self.levelIndicator.minValue = range.lowerBound
		self.levelIndicator.maxValue = range.upperBound
		self.levelIndicator.doubleValue = value
	}

	/// Create a level indicator
	/// - Parameters:
	///   - valueBinder: The value binder
	///   - range: The allowable range of values
	public convenience init(
		style: NSLevelIndicator.Style,
		value: ValueBinder<Double>,
		range: ClosedRange<Double> = 0 ... 100
	) {
		self.init()

		self.levelIndicator.levelIndicatorStyle = style
		self.levelIndicator.minValue = range.lowerBound
		self.levelIndicator.maxValue = range.upperBound
		self.bindValue(value)
	}

	internal override init() {
		super.init()
		self.levelIndicator.isContinuous = true
		self.levelIndicator.levelIndicatorStyle = .continuousCapacity
		self.setupListener()
	}

	deinit {
		self.actionCallback = nil
		self.valueObserver = nil
		self.isEditableBinder?.deregister(self)
		self.isEditableBinder = nil
		self.valueBinder?.deregister(self)
		self.valueBinder = nil
		self.rangeBinder?.deregister(self)
		self.rangeBinder = nil
	}

	// Private
	private let levelIndicator = NSLevelIndicator()
	override public func view() -> NSView { return self.levelIndicator }

	private var valueObserver: NSKeyValueObservation?

	private var isEditableBinder: ValueBinder<Bool>?
	private var valueBinder: ValueBinder<Double>?
	private var rangeBinder: ValueBinder<ClosedRange<Double>>?

	private var actionCallback: ((Double) -> Void)?
}

private extension LevelIndicator {
	func setupListener() {
		guard let cell = self.levelIndicator.cell else { fatalError() }
		self.valueObserver = cell.observe(\.doubleValue, options: [.old, .new]) { [weak self] _, change in
			if let old = change.oldValue, let new = change.newValue, new != old {
				self?.valueDidChange(new)
			}
		}
	}

	func valueDidChange(_ value: Double) {
		// Call the callback if it is set
		self.actionCallback?(value)

		// Tell the binder to update
		self.valueBinder?.wrappedValue = value
	}
}

// MARK: - Actions

public extension LevelIndicator {
	/// Set a callback block for when the selection changes
	func onChange(_ block: @escaping (Double) -> Void) -> Self {
		self.actionCallback = block
		return self
	}
}

// MARK: - Modifiers

public extension LevelIndicator {
	/// Is the level indicator changeable by the user?
	@discardableResult func isEditable(_ editable: Bool) -> Self {
		self.levelIndicator.isEditable = editable
		return self
	}

	/// Set the level indicator='s fill color
	/// - Parameter color: The color
	/// - Returns: self
	@discardableResult func fillColor(_ color: NSColor) -> Self {
		self.levelIndicator.fillColor = color
		return self
	}

	/// Set the warning value and color for the indicator
	/// - Parameters:
	///   - value: The warning value of the level indicator control
	///   - color: The color to use when the value is in the warning range
	/// - Returns: self
	@discardableResult func warning(_ value: Double, color: NSColor) -> Self {
		assert(value >= self.levelIndicator.minValue)
		assert(value <= self.levelIndicator.maxValue)
		self.levelIndicator.warningValue = value
		self.levelIndicator.warningFillColor = color
		return self
	}

	/// Set the critical value and color for the indicator
	/// - Parameters:
	///   - value: The critical value of the level indicator control
	///   - color: The color to use when the value is in the critical range
	/// - Returns: self
	@discardableResult func critical(_ value: Double, color: NSColor) -> Self {
		assert(value >= self.levelIndicator.minValue)
		assert(value <= self.levelIndicator.maxValue)
		self.levelIndicator.criticalValue = value
		self.levelIndicator.criticalFillColor = color
		return self
	}
}

// MARK: - Bindings

public extension LevelIndicator {
	/// Bind the level indicator's value
	/// - Parameter value: The value binding
	/// - Returns: self
	@discardableResult func bindValue(_ value: ValueBinder<Double>) -> Self {
		self.valueBinder = value
		value.register { [weak self] newValue in
			self?.levelIndicator.doubleValue = newValue
		}
		return self
	}

	/// Bind the level indicator's range
	/// - Parameter binder: The range binder
	/// - Returns: self
	@discardableResult func bindRange(_ binder: ValueBinder<ClosedRange<Double>>) -> Self {
		self.rangeBinder = binder
		binder.register { [weak self] newValue in
			guard let `self` = self else { return }
			self.levelIndicator.minValue = newValue.lowerBound
			self.levelIndicator.maxValue = newValue.upperBound
		}
		return self
	}

	/// Bind the level indicator's editable flag
	/// - Parameter binder: The isEditable binder
	/// - Returns: self
	@discardableResult func bindIsEditable(_ binder: ValueBinder<Bool>) -> Self {
		self.isEditableBinder = binder
		binder.register { [weak self] newValue in
			guard let `self` = self else { return }
			self.levelIndicator.isEditable = newValue
		}
		return self
	}
}
