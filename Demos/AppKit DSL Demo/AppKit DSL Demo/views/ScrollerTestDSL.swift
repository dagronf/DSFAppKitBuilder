//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

class ScrollerTestDSL: NSObject, DSFAppKitBuilderViewHandler {

	let playsound = ValueBinder<Int>(0) { newValue in
		Swift.print("playsound is now \(newValue)")
	}

	lazy var body: Element =
		ScrollView(borderType: .lineBorder, fitHorizontally: true) {
			VStack(spacing: 16, alignment: .leading) {
				HStack(alignment: .lastBaseline) {
					CheckBox("Play sound")
					PopupButton {
						MenuItem("Purr")
						MenuItem("Sosumi")
					}
					.bindSelection(playsound)
					.horizontalPriorities(hugging: 100)
				}

				HStack(alignment: .lastBaseline) {
					CheckBox("Speak announcement using")
					PopupButton {
						MenuItem("Daniel")
						MenuItem("Catherine")
						MenuItem("Fiona")
					}
					.horizontalPriorities(hugging: 100)
				}

				HStack(alignment: .lastBaseline) {
					CheckBox("Notify using system notification")
						.horizontalPriorities(hugging: 100)
				}

				HStack(alignment: .lastBaseline) {
					CheckBox("Bounce Xcode icon in Dock if application inactive")
						.horizontalPriorities(hugging: 100)
				}

				HDivider()

				HStack(alignment: .lastBaseline) {
					CheckBox("")
					Label("Show")
					PopupButton {
						MenuItem("window tab")
					}
					Label("named")
					TextField("Window Name")
				}
				HStack(alignment: .lastBaseline) {
					CheckBox("")
					PopupButton {
						MenuItem("Show")
						MenuItem("Hide")
					}
					.horizontalPriorities(compressionResistance: 100)
					Label("navigator")
					PopupButton {
						MenuItem("Current")
						MenuItem("Files")
						MenuItem("Changes")
					}
					EmptyView()
				}

				HStack(alignment: .lastBaseline) {
					CheckBox("")
					PopupButton {
						MenuItem("Show")
						MenuItem("Hide")
						MenuItem("If no output, hide")
					}
					.horizontalPriorities(compressionResistance: 100)
					.minWidth(100)
					Label("debugger with")
					PopupButton {
						MenuItem("Current Views")
						MenuItem("Variable Console Views")
					}
					.horizontalPriorities(compressionResistance: 100)
					EmptyView()
				}

				HStack(alignment: .lastBaseline) {
					CheckBox("")
					PopupButton {
						MenuItem("Show")
						MenuItem("Hide")
					}
					Label("inspectors")
					EmptyView()
				}

				// Toolbars
				toolbars

				// Editor
				currentEditor
			}
			.edgeInsets(16)
		}

	// MARK: - Toolbar



	let toolbar_enable = ValueBinder<Bool>(false)
	let toolbar_show_state = ValueBinder<Int>(0)

	lazy var toolbars: Element =
		HStack(alignment: .lastBaseline) {
			CheckBox()
				.state(toolbar_enable.wrappedValue ? .on : .off)
				.bindOnOffState(self.toolbar_enable)
			PopupButton {
				MenuItem("Show")
				MenuItem("Hide")
			}
			.bindIsEnabled(self.toolbar_enable)
			.bindSelection(self.toolbar_show_state)
			Label("toolbars")
			EmptyView()
		}

	// MARK: - Editor

	let currentEditor_enable = ValueBinder<Bool>(false)
	lazy var currentEditor: Element =
		HStack(alignment: .lastBaseline) {
			CheckBox()
				.bindOnOffState(self.currentEditor_enable)
			PopupButton {
				MenuItem("Show")
				MenuItem("Hide")
			}
			.bindIsEnabled(self.currentEditor_enable)
			PopupButton {
				MenuItem("Current Editor")
			}
			.bindIsEnabled(self.currentEditor_enable)
			Label("in")
			PopupButton {
				MenuItem("Focused Editor")
			}
			.bindIsEnabled(self.currentEditor_enable)
			EmptyView()
		}
}
