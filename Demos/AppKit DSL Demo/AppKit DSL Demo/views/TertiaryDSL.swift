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

	let toggleState1 = ValueBinder(Toggle.State.on)
	let toggleState2 = ValueBinder(Toggle.State.off)
	let toggleColor = ValueBinder<NSColor>(NSColor.systemBlue)
	let toggleColorEnabled = ValueBinder(Toggle.State.on)
	let toggleColorEnabled2 = ValueBinder(Toggle.State.on)

	let __searchText = ValueBinder("")
	let __searchSubmittedText = ValueBinder("")
	let __searchText2 = ValueBinder("")
	let __searchSubmittedText2 = ValueBinder("")

	override init() {
		super.init()
	}

	// body

	lazy var body: Element =
		VStack(alignment: .leading) {
			HStack(spacing: 4) {
				Toggle(state: toggleState1)
					.size(width: 100, height: 50)
				Toggle(state: toggleState2, showLabels: true)
					.size(width: 100, height: 50)

				VDivider()

				Toggle(state: toggleState2, showLabels: true)
					.bindColor(toggleColor)
					.bindIsEnabled(toggleColorEnabled.boolValue())
					.size(width: 200, height: 100)
				VStack {
					HStack {
						ColorWell(showsAlpha: true)
							.bindColor(toggleColor)
							.bindIsEnabled(toggleColorEnabled2.boolValue())
							.size(width: 60, height: 40)
						Toggle(state: toggleColorEnabled2)
							.size(width: 40, height: 20)
					}
					HStack {
						Label("Enable Button")
						Toggle(state: toggleColorEnabled)
							.size(width: 40, height: 20)
					}
				}
			}

			HDivider()

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

			HDivider()

			///
			HStack {
				Box("Binding update for all changes") {
					VStack(alignment: .leading) {
						SearchField(searchTermBinder: __searchText, searchBinderUpdateType: .all)
							.onSubmit { [weak self] newValue in
								self?.__searchSubmittedText.wrappedValue = newValue
							}
						HStack {
							Label("Search text:")
							TextField()
								.bindText(__searchText)
						}
						HStack {
							Label("Last submit:")
							Label()
								.bindLabel(__searchSubmittedText)
						}
					}
				}
				.width(250)

				VDivider()

				Box("Binding update on submit only") {
					VStack(alignment: .leading) {
						SearchField(searchTermBinder: __searchText2, searchBinderUpdateType: .submitOnly)
							.onSubmit { [weak self] newValue in
								self?.__searchSubmittedText2.wrappedValue = newValue
							}
						HStack {
							Label("Search text:")
							TextField()
								.bindText(__searchText2)
						}
						HStack {
							Label("Last submit:")
							Label()
								.bindLabel(__searchSubmittedText2)
						}
					}
				}
				.width(250)
			}

			///

			EmptyView()
				.verticalPriorities(hugging: 10, compressionResistance: 10)
		}
		.padding(16)
}
