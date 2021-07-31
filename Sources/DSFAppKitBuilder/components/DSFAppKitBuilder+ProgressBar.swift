//
//  DSFAppKitBuilder+ProgressBar.swift
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

import AppKit.NSProgressIndicator

public class ProgressBar: Element {
	public init(
		indeterminite: Bool = false,
		range: ClosedRange<Double> = 0 ... 100,
		value: Double = 20
	) {
		super.init()
		
		self.progress.isIndeterminate = false
		self.progress.minValue = range.lowerBound
		self.progress.maxValue = range.upperBound
		self.progress.doubleValue = value
		self.progress.isIndeterminate = indeterminite
	}
	
	// Private
	
	override var nsView: NSView { return self.progress }
	
	private let progress = NSProgressIndicator()
	private lazy var progressBinder = Bindable<Double>()
}

// MARK: - Bindings

public extension ProgressBar {
	/// Bind the value of the progress bar to a keypath
	func bindValue<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Double>) -> Self {
		self.progressBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.progress.doubleValue = newValue
		})
		return self
	}
}
