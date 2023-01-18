//
//  DSFAppKitBuilder+DatePicker.swift
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

import Foundation
import AppKit
import DSFValueBinders

/// A date picker element
///
/// Usage:
///
/// ```swift
/// let dateSelection1 = ValueBinder(Date())
/// ...
/// DatePicker(date: dateSelection)
/// ```
public class DatePicker: Control {
	/// Create a DatePicker with a single selection mode
	public init(
		date: ValueBinder<Date>,
		style: NSDatePicker.Style? = nil,
		elements: NSDatePicker.ElementFlags? = nil
	) {
		self.bindDate = date
		super.init()

		picker.datePickerMode = .single
		if let style = style {
			self.picker.datePickerStyle = style
		}

		if let elements = elements {
			self.picker.datePickerElements = elements
		}

		picker.dateValue = date.wrappedValue

		picker.target = self
		picker.action = #selector(dateDidChange(_:))

		date.register { [weak self] newDate in
			self?.picker.dateValue = newDate
		}
	}

	/// Create a DatePicker with a range selection mode
	public init(
		range: ValueBinder<DatePicker.Range>,
		style: NSDatePicker.Style? = nil,
		elements: NSDatePicker.ElementFlags? = nil
	) {
		self.bindDateRange = range
		super.init()

		picker.datePickerMode = .range
		if let style = style {
			self.picker.datePickerStyle = style
		}
		if let elements = elements {
			self.picker.datePickerElements = elements
		}

		picker.dateValue = range.wrappedValue.startDate
		picker.timeInterval = range.wrappedValue.timeInterval

		picker.target = self
		picker.action = #selector(dateDidChange(_:))

		range.register { [weak self] newRange in
			self?.picker.dateValue = newRange.startDate
			self?.picker.timeInterval = newRange.timeInterval
		}
	}

	@objc private func dateDidChange(_ sender: NSDatePicker) {
		if let d = self.bindDate {
			d.wrappedValue = sender.dateValue
		}
		else if let d = self.bindDateRange {
			d.wrappedValue = Range(date: sender.dateValue, timeInterval: sender.timeInterval)
		}
	}

	deinit {
		self.bindDate?.deregister(self)
		self.bindDateRange?.deregister(self)
		self.bindMinDate?.deregister(self)
		self.bindMaxDate?.deregister(self)
	}

	private let picker = NSDatePicker()
	public override func view() -> NSView { return self.picker }

	private var bindDate: ValueBinder<Date>?
	private var bindDateRange: ValueBinder<Range>?
	private var bindMinDate: ValueBinder<Date>?
	private var bindMaxDate: ValueBinder<Date>?
}

// MARK: Bindings

public extension DatePicker {
	/// Bind the minimum selectable date
	func bindMinDate(_ valueBinder: ValueBinder<Date>) -> Self {
		self.bindMinDate = valueBinder
		valueBinder.register { [weak self] newValue in
			self?.picker.minDate = newValue
		}
		return self
	}

	/// Bind the maximum selectable date
	func bindMaxDate(_ valueBinder: ValueBinder<Date>) -> Self {
		self.bindMaxDate = valueBinder
		valueBinder.register { [weak self] newValue in
			self?.picker.maxDate = newValue
		}
		return self
	}
}

// MARK: Modifiers

public extension DatePicker {
	/// The text color
	func textColor(_ color: NSColor) -> Self {
		self.picker.textColor = color
		return self
	}

	/// Set the color of the background for the date picker
	func pickerBackgroundColor(_ color: NSColor) -> Self {
		self.picker.backgroundColor = color
		return self
	}

	/// Set date picker has a plain border.
	func isBordered(_ state: Bool) -> Self {
		self.picker.isBordered = state
		return self
	}

	/// Set date picker has a bezel
	func isBezeled(_ state: Bool) -> Self {
		self.picker.isBezeled = state
		return self
	}
}

public extension DatePicker {
	/// Set the selectable date range
	func range(min: Date? = nil, max: Date? = nil) -> Self {
		self.picker.minDate = min
		self.picker.maxDate = max
		return self
	}

	/// Set the calendar to use
	func calendar(_ calendar: Calendar) -> Self {
		self.picker.calendar = calendar
		return self
	}

	/// Set the locale
	func locale(_ locale: Locale) -> Self {
		self.picker.locale = locale
		return self
	}

	/// Set the timezone
	func timeZone(_ timeZone: TimeZone) -> Self {
		self.picker.timeZone = timeZone
		return self
	}
}

public extension DatePicker {
	/// A DatePicker date range type
	class Range: CustomDebugStringConvertible {
		// The start date
		public let startDate: Date
		// The time interval from `date`
		public let timeInterval: TimeInterval
		// The end date
		public var endDate: Date {
			self.startDate.addingTimeInterval(self.timeInterval)
		}

		public var debugDescription: String {
			"start: \(self.startDate), end: \(self.endDate), interval: \(self.timeInterval), "
		}

		/// Create a date range
		public init() {
			self.startDate = Date()
			self.timeInterval = 0
		}

		/// Create a date range
		public init(date: Date, timeInterval: TimeInterval) {
			self.startDate = date
			self.timeInterval = timeInterval
		}
	}
}

#if DEBUG && canImport(SwiftUI)
let __previewDate = ValueBinder(Date())
import SwiftUI
@available(macOS 10.15, *)
struct DatePickerPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack(alignment: .leading) {
				VStack(alignment: .leading) {
					Label("Default").font(NSFont.boldSystemFont(ofSize: 14))
					HStack {
						DatePicker(date: __previewDate)
						DatePicker(date: __previewDate)
							.isEnabled(false)
					}
					HStack {
						DatePicker(date: __previewDate, style: .textField)
						DatePicker(date: __previewDate, style: .textField)
							.isEnabled(false)
					}
				}
				HDivider()
				VStack(alignment: .leading) {
					Label("Components").font(NSFont.boldSystemFont(ofSize: 14))
					Grid {
						GridRow(rowAlignment: .firstBaseline) {
							Label("Year Month")
							DatePicker(date: __previewDate, elements: .yearMonth)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("Year Month Day")
							DatePicker(date: __previewDate, elements: .yearMonthDay)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("Hour Minute Second")
							DatePicker(date: __previewDate, elements: .hourMinuteSecond)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("Year Month Hour Minute")
							DatePicker(date: __previewDate, elements: [.hourMinute, .yearMonth])
						}
					}
				}
				HDivider()
				HStack {
					VStack(alignment: .leading) {
						Label("GMT Timezone").font(NSFont.boldSystemFont(ofSize: 16))
						DatePicker(date: __previewDate)
							.locale(Locale.current)
							.timeZone(TimeZone(identifier: "GMT")!)
					}
					VStack(alignment: .leading) {
						Label("French Locale").font(NSFont.boldSystemFont(ofSize: 16))
						DatePicker(date: __previewDate)
							.locale(Locale(identifier: "FR-fr"))
					}
				}
				HDivider()
				VStack(alignment: .leading) {
					Label("Clock and Calendar").font(NSFont.boldSystemFont(ofSize: 16))
					DatePicker(date: __previewDate, style: .clockAndCalendar)
						.locale(Locale(identifier: "GMT"))
				}
				HDivider()
				VStack(alignment: .leading) {
					Label("Bezels and borders").font(NSFont.boldSystemFont(ofSize: 16))
					HStack {
						DatePicker(date: __previewDate)
						DatePicker(date: __previewDate)
							.isBezeled(false)
					}
					HStack {
						DatePicker(date: __previewDate)
							.isBordered(false)
						DatePicker(date: __previewDate)
							.isBordered(true)
					}
				}
				HDivider()
				VStack(alignment: .leading) {
					Label("Colors").font(NSFont.boldSystemFont(ofSize: 16))
					HStack {
						DatePicker(date: __previewDate)
							.textColor(NSColor.systemPurple)
						DatePicker(date: __previewDate)
							.textColor(NSColor.systemRed)
					}
				}
			}
			.SwiftUIPreview()
		}
		.padding()
		.frame(width: 400)
	}
}
#endif
