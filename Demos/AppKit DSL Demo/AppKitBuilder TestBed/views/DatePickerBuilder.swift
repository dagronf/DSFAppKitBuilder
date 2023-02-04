//
//  DatePicker.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 3/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders

public class DatePickerBuilder: ViewTestBed {
	var title: String { "Date Picker" }
	var description: String { "Displays a date picker with support for different styles, locales and timezones" }
	func build() -> ElementController {
		DatePickerBuilderController()
	}
}

class DatePickerBuilderController: ElementController {
	let __previewDate = ValueBinder(Date())

	lazy var body: Element = {
		VStack(alignment: .leading) {
			VStack(alignment: .leading) {
				Label("Default").font(NSFont.boldSystemFont(ofSize: 14))
				HStack {
					DatePicker(date: self.__previewDate)
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
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct DatePickerPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack(alignment: .leading) {
				DatePickerBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
