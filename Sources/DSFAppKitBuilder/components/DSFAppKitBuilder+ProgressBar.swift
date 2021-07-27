//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSProgressIndicator

public class ProgressBar: Element {
	let progress = NSProgressIndicator()
	public override var nsView: NSView { return self.progress }

	public init(
		tag: Int? = nil,
		indeterminite: Bool = false,
		range: ClosedRange<Double> = 0...100,
		value: Double = 20
	) {
		super.init(tag: tag)

		self.progress.isIndeterminate = false
		self.progress.minValue = range.lowerBound
		self.progress.maxValue = range.upperBound
		self.progress.doubleValue = value
		self.progress.isIndeterminate = indeterminite
	}

	private lazy var progressBinder = Bindable<Double>()
	public func bindValue<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Double>) -> Self {
		self.progressBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.progress.doubleValue = newValue
		})
		self.progressBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}
}
