//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder

class ScrollerTestDSL: NSObject, DSFAppKitBuilderViewHandler {
	lazy var body: Element =
		ScrollView(borderType: .lineBorder, fitHorizontally: true) {
			VStack(spacing: 16, alignment: .leading) {
				HStack(alignment: .lastBaseline) {
					CheckBox("Play sound")
					PopupButton {
						MenuItem(title: "Purr")
						MenuItem(title: "Sosumi")
					}
					.horizontalPriorities(hugging: 100)
				}

				HStack(alignment: .lastBaseline) {
					CheckBox("Speak announcement using")
					PopupButton {
						MenuItem(title: "Daniel")
						MenuItem(title: "Catherine")
						MenuItem(title: "Fiona")
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
					CheckBox()
					Label("Show")
					PopupButton {
						MenuItem(title: "window tab")
					}
					Label("named")
					TextField("Window Name")
				}
				HStack(alignment: .lastBaseline) {
					CheckBox()
					PopupButton {
						MenuItem(title: "Show")
						MenuItem(title: "Hide")
					}
					.horizontalPriorities(compressionResistance: 100)
					Label("navigator")
					PopupButton {
						MenuItem(title: "Current")
						MenuItem(title: "Files")
						MenuItem(title: "Changes")
					}
					EmptyView()
				}

				HStack(alignment: .lastBaseline) {
					CheckBox()
					PopupButton {
						MenuItem(title: "Show")
						MenuItem(title: "Hide")
						MenuItem(title: "If no output, hide")
					}
					.horizontalPriorities(compressionResistance: 100)
					.minWidth(100)
					Label("debugger with")
					PopupButton {
						MenuItem(title: "Current Views")
						MenuItem(title: "Variable Console Views")
					}
					.horizontalPriorities(compressionResistance: 100)
					EmptyView()
				}

				HStack(alignment: .lastBaseline) {
					CheckBox()
					PopupButton {
						MenuItem(title: "Show")
						MenuItem(title: "Hide")
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

	@objc dynamic var toolbar_enable: Bool = false
	@objc dynamic var toolbar_show_state: Int = 0

	lazy var toolbars: Element =
		HStack(alignment: .lastBaseline) {
			CheckBox().state(toolbar_enable ? .on : .off)
				.bindOnOffState(self, keyPath: \ScrollerTestDSL.toolbar_enable)
			PopupButton {
				MenuItem(title: "Show")
				MenuItem(title: "Hide")
			}
			.bindIsEnabled(self, keyPath: \ScrollerTestDSL.toolbar_enable)
			.bindSelection(self, keyPath: \ScrollerTestDSL.toolbar_show_state)
			Label("toolbars")
			EmptyView()
		}

	// MARK: - Editor

	@objc dynamic var currentEditor_enable: Bool = false
	lazy var currentEditor: Element =
		HStack(alignment: .lastBaseline) {
			CheckBox()
				.bindOnOffState(self, keyPath: \ScrollerTestDSL.currentEditor_enable)
			PopupButton {
				MenuItem(title: "Show")
				MenuItem(title: "Hide")
			}
			.bindIsEnabled(self, keyPath: \ScrollerTestDSL.currentEditor_enable)
			PopupButton {
				MenuItem(title: "Current Editor")
			}
			.bindIsEnabled(self, keyPath: \ScrollerTestDSL.currentEditor_enable)
			Label("in")
			PopupButton {
				MenuItem(title: "Focused Editor")
			}
			.bindIsEnabled(self, keyPath: \ScrollerTestDSL.currentEditor_enable)
			EmptyView()
		}
}
