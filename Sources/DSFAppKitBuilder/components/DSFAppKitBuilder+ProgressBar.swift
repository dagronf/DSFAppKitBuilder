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

/// Wrapper for NSProgressIndicator
///
/// Usage:
///
/// ```swift
/// ProgressBar(range: 0...1)
///    .bindValue(self, keyPath: \MyObject.progressValue)
/// ```
public class ProgressBar: Element {

	/// Create a ProgressBar instance
	/// - Parameters:
	///   - style: The style of the progress indicator (bar or spinning).
	///   - indeterminite: A Boolean that indicates whether the progress indicator is indeterminate.
	///   - range: The value range for the progressbar
	///   - value: The initial value
	public init(
		style: NSProgressIndicator.Style = .bar,
		indeterminite: Bool = false,
		range: ClosedRange<Double> = 0 ... 100,
		value: Double = 0
	) {
		super.init()

		self.progress.style = style
		self.progress.isIndeterminate = false
		self.progress.minValue = range.lowerBound
		self.progress.maxValue = range.upperBound
		self.progress.doubleValue = value
		self.progress.isIndeterminate = indeterminite
	}

	/// For an indeterminite progress bar, start animating
	public func startAnimating() {
		self.progress.startAnimation(self)
	}

	/// For an indeterminite progress bar, stop animating
	public func stopAnimating() {
		self.progress.stopAnimation(self)
	}

	
	// Private
	
	override var nsView: NSView { return self.progress }
	
	private let progress = NSProgressIndicator()
	private lazy var progressBinder = Bindable<Double>()
}

// MARK: - Modifiers

public extension ProgressBar {

	/// A Boolean that indicates whether the progress indicator implements animation in a separate thread.
	///
	/// See [Apple's Documentation](https://developer.apple.com/documentation/appkit/nsprogressindicator/1501160-usesthreadedanimation)
	func usesThreadedAnimation(_ isThreaded: Bool) -> Self {
		self.progress.usesThreadedAnimation = isThreaded
		return self
	}
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
