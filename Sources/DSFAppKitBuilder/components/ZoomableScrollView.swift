//
//  ZoomableScrollView.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

import AppKit
import DSFValueBinders

// MARK: - Zoom scroll view

public class ZoomableScrollView: ScrollView {
	public override var clipType: NSClipView.Type { CenteringClipView.self }

	/// Create a ScrollView
	/// - Parameters:
	///   - fitHorizontally: Fix the width of the content to the width of the scrollview (so no horizontal scroller)
	///   - autohidesScrollers: A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	///   - documentElement: The content of the scrollview
	public convenience init(
		scaleBinder: ValueBinder<Double>,
		range: ClosedRange<Double>,
		borderType: NSBorderType = .lineBorder,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		_ builder: () -> Element
	) {
		self.init(
			scaleBinder: scaleBinder,
			range: range,
			borderType: borderType,
			fitHorizontally: fitHorizontally,
			autohidesScrollers: autohidesScrollers,
			content: builder()
		)
	}

	public init(
		scaleBinder: ValueBinder<Double>,
		range: ClosedRange<Double>,
		borderType: NSBorderType = .lineBorder,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		content: Element
	) {
		self.range = range
		self.scaleBinder = scaleBinder

		super.init(
			borderType: borderType,
			fitHorizontally: fitHorizontally,
			autohidesScrollers: autohidesScrollers,
			content: content
		)
	}

	deinit {
		self.magnifyObserver = nil
		self.scaleBinder.deregister(self)
	}

	override func customSetup() {
		self.scrollView.allowsMagnification = true
		self.scrollView.minMagnification = range.lowerBound
		self.scrollView.maxMagnification = range.upperBound

		self.magnifyObserver = self.scrollView.observe(\.magnification, options: [.new]) { [weak self] scrollView, change in
			guard let `self` = self, let newValue = change.newValue else { return }
			self.updateScale.tryLock {
				Swift.print("New value: \(newValue)")
				self.scaleBinder.wrappedValue = newValue
				self.syncZoomFitScale()
			}
		}

		self.scrollView.allowsMagnification = true

		self.scaleBinder.register(self) { [weak self] newScale in
			guard let `self` = self else { return }
			self.updateScale.tryLock {
				self.scale(newScale)
			}
		}
	}

	private let scaleBinder: ValueBinder<Double>
	private let range: ClosedRange<Double>
	private var magnifyObserver: NSKeyValueObservation?
	private var updateScale = ProtectedLock()

	private var zoomToFitScaleBinder: ValueBinder<Double>?
}

// MARK: - Binders

public extension ZoomableScrollView {
	/// Bind the scale required for a 'zoom-to-fit' to a valuebinder
	///
	/// Useful if you want to have a 'zoom to fit' button on your UI, and you need to extract
	/// the scale value that will scale the content appropriately
	func bindZoomToFitScale(_ value: ValueBinder<Double>) -> Self {
		self.zoomToFitScaleBinder = value
		value.register(self) { _ in
			// Do nothing
		}
		return self
	}
}

extension ZoomableScrollView {
	func scale(_ scaleFactor: CGFloat) {
		//self.scrollView.animator().magnification = scaleFactor
		self.scrollView.magnification = scaleFactor
		self.syncZoomFitScale()
	}

	func syncZoomFitScale() {
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			let contentRect = self.scrollView.contentView.frame
			let documentRect = self.scrollView.documentView!.bounds
			let dx = contentRect.size.width / documentRect.size.width
			let dy = contentRect.size.height / documentRect.size.height
			self.zoomToFitScaleBinder?.wrappedValue = min(dx, dy)
		}
	}

	func zoomToFit() {
		if let sz = self.scrollView.documentView?.bounds {
			self.scrollView.magnify(toFit: sz)
		}
	}

//	func zoomToFitScale() -> Double {
//		let contentRect = self.scrollView.contentView.frame
//		let documentRect = self.scrollView.documentView!.bounds
//
//		let dx = contentRect.size.width / documentRect.size.width
//		let dy = contentRect.size.height / documentRect.size.height
//
//		return min(dx, dy)
//	}
}
