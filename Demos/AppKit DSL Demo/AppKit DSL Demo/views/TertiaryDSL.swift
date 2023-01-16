//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class TertiaryDSL: NSObject, DSFAppKitBuilderViewHandler {

	let dateSelection1 = ValueBinder(Date()) { newValue in
		Swift.print("dateSelection1 is now \(newValue)")
	}
	let dateSelection2 = ValueBinder(Date().addingTimeInterval(-3600)) { newValue in
		Swift.print("dateSelection2 is now \(newValue)")
	}
	let dateTimeRangeSelection = ValueBinder(DatePicker.Range()) { newValue in
		Swift.print("dateTimeRangeSelection is now \(newValue)")
	}
	let dateSelectionMinMax = ValueBinder(Date()) { newValue in
		Swift.print("dateSelectionMinMax is now \(newValue)")
	}

	override init() {
		super.init()
	}

	// body

	lazy var body: Element =
	Group(edgeInset: 16) {
		VStack(alignment: .leading) {
			HStack {
				DatePicker(date: dateSelection1)
				Button(title: "Now") { [weak self] _ in
					self?.dateSelection1.wrappedValue = Date()
				}
			}
			HStack {
				DatePicker(date: dateSelection2)
					.locale(Locale(identifier: "GMT"))
				Button(title: "Now") { [weak self] _ in
					self?.dateSelection2.wrappedValue = Date()
				}
			}
			HStack {
				DatePicker(
					range: dateTimeRangeSelection,
					style: .clockAndCalendar
				)
				Button(title: "Now") { [weak self] _ in
					self?.dateTimeRangeSelection.wrappedValue = DatePicker.Range()
				}
			}
			Label("Only allow selecting dates from the current time onwards")
			HStack {
				DatePicker(date: dateSelectionMinMax)
					.range(min: Date())
				Button(title: "Now") { [weak self] _ in
					self?.dateSelectionMinMax.wrappedValue = Date()
				}
			}
			EmptyView()
				.verticalPriorities(hugging: 10, compressionResistance: 10)
		}
	}
}
