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

import Foundation
import AppKit

import DSFPagerControl
import DSFValueBinders

/// Wrapper for DSFPagerControl
///
/// Usage:
///
/// ```swift
/// Pager(
///    pageCount: 7,
///    selectedPage: $selectedPage,
///    allowsMouseInteration: true,
///    selectedColor: .systemYellow,
///    unselectedColor: .systemYellow.withAlphaComponent(0.2)
///)
/// ```
public class Pager: Control {
	/// Create a level indicator
	/// - Parameters:
	///   - indicatorShape: The indicator shape
	///   - pageCount: The number of pages
	///   - selectedPage: A binder for the selected page
	///   - allowsKeyboardInteration: If true, allows the user to use the keyboard to change the selected page
	///   - allowsMouseInteration: If true, allows the user to use a mouse/trackpad to change the selected page
	///   - selectedColor: The color for the selected page indicator
	///   - unselectedColor: The color for a page indicator that is not selected
	///   - bordered: If true, draws a border around the page indicators
	public init(
		indicatorShape: DSFPagerControlIndicatorShape = DSFPagerControl.HorizontalIndicatorShape(),
		pageCount: Int,
		selectedPage: ValueBinder<Int>,
		allowsKeyboardInteration: Bool = false,
		allowsMouseInteration: Bool = false,
		selectedColor: NSColor? = nil,
		unselectedColor: NSColor? = nil,
		bordered: Bool = false
	) {
		self.pagerControl.indicatorShape = indicatorShape
		self.pagerControl.pageCount = pageCount
		self.pagerControl.allowsKeyboardFocus = allowsKeyboardInteration
		self.pagerControl.allowsMouseSelection = allowsMouseInteration

		if let s = selectedColor {
			self.pagerControl.selectedColor = s
		}
		if let s = unselectedColor {
			self.pagerControl.unselectedColor = s
		}
		self.pagerControl.bordered = bordered

		self.selectedPageBinder = selectedPage

		super.init()

		self.pagerControl.delegate = self

		selectedPage.register(self) { [weak self] newValue in
			// Reflect the selected page out
			self?.pagerControl.selectedPage = newValue
			// Call the action block if it has been specified
			self?.actionCallback?(newValue)
		}
	}

	deinit {
		self.selectedPageBinder.deregister(self)
		self.pageCountBinder?.deregister(self)

		self.pageCountBinder = nil
		self.validatePageChangeBlock = nil
		self.actionCallback = nil
	}

	// Private
	private let pagerControl = DSFPagerControl()
	override public func view() -> NSView { return self.pagerControl }

	private var selectedPageBinder: ValueBinder<Int>
	private var pageCountBinder: ValueBinder<Int>?
	private var validatePageChangeBlock: ((Int) -> Bool)?
	private var actionCallback: ((Int) -> Void)?
}

// MARK: - Actions

public extension Pager {
	/// Supply a block that will be called to validate the change of page
	/// - Parameter block: The validation block
	/// - Returns: self
	func willChangeToPage(_ block: @escaping (Int) -> Bool) -> Self {
		self.validatePageChangeBlock = block
		return self
	}

	/// Supply a block that is called then the page changes
	/// - Parameter block: The block
	/// - Returns: self
	func didChangeToPage(_ block: @escaping (Int) -> Void) -> Self {
		self.actionCallback = block
		return self
	}
}

// MARK: - Modifiers

public extension Pager { }

// MARK: - Bindings

public extension Pager { 
	/// Bind the page count
	/// - Parameter value: The page count binder value
	/// - Returns: self
	func bindPageCount(_ value: ValueBinder<Int>) -> Self {
		self.pageCountBinder = value
		value.register(self) { [weak self] newPageCount in
			self?.pagerControl.pageCount = newPageCount
		}
		return self
	}
}

// MARK: Pager delegate

extension Pager: DSFPagerControlHandling {
	public func pagerControl(_ pager: DSFPagerControl, didMoveToPage page: Int) {
		if page != selectedPageBinder.wrappedValue {
			selectedPageBinder.wrappedValue = page
		}
	}

	public func pagerControl(_ pager: DSFPagerControl, willMoveToPage page: Int) -> Bool {
		if let validate = self.validatePageChangeBlock {
			return validate(page)
		}
		return true
	}
}
