//
//  GridDSL.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 31/8/21.
//

import AppKit
import DSFAppKitBuilder

class GridDSL: NSObject, DSFAppKitBuilderViewHandler {

//	let showTextStyleBinder = ElementBinder()
//	let showAlertBinder = ElementBinder()

	lazy var body: Element =
		Group(layoutType: .center) {
			Grid {
				GridRow(bottomPadding: 5) {
					Label("Braille Translation:")
					PopupButton {
						MenuItem(title: "English (Unified)")
						MenuItem(title: "United States")
					}
				}
				GridRow {
					EmptyView()
					CheckBox("Show Contracted Braille")
				}
				GridRow(bottomPadding: 5) {
					EmptyView()
					CheckBox("Show Eight Dot Braille")
				}
				GridRow {
					Label("Status Cells:")
					CheckBox("Show General Display Status")
				}
				GridRow(bottomPadding: 5) {
					EmptyView()
					CheckBox("Show Text Style")
//						.bindElement(self.showTextStyleBinder)
				}
				GridRow(mergeCells: [0 ... 1]) {
					CheckBox("Show alert messages for duration")
//						.bindElement(self.showAlertBinder)
					EmptyView()
				}
			}
			.columnFormatting(xPlacement: .trailing, trailingPadding: 5, atColumn: 0)
			.cellFormatting(xPlacement: .center, atRowIndex: 5, columnIndex: 0)

//			.addingCellContraints(atRowIndex: 5, columnIndex: 0) { [weak self] in
//				guard let `self` = self,
//						let showTextStyle = self.showTextStyleBinder.view,
//						let showAlert = self.showAlertBinder.view else { return [] }
//				return [showAlert.centerXAnchor.constraint(equalTo: showTextStyle.leadingAnchor)]
//			}

			.applyRecursively { element in
				_ = element.border(width: 0.5, color: NSColor.red)
			}
		}
}
