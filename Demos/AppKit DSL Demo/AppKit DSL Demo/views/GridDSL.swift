//
//  GridDSL.swift
//  AppKit DSL Demo
//
//  Created by Darren Ford on 31/8/21.
//

import AppKit
import DSFAppKitBuilder
import DSFMenuBuilder

class GridDSL: NSObject, DSFAppKitBuilderViewHandler {

	let showTextStyleBinder = ElementBinder()
	let showAlertBinder = ElementBinder()

	let showContractedBraille = ValueBinder(false) { newValue in
		Swift.print("Show Contracted Braille is now \(newValue)")
	}
	let showEightDotBraille = ValueBinder(true) { newValue in
		Swift.print("Show Eight Dot Braille is now \(newValue)")
	}

	lazy var body: Element =
		Group(layoutType: .center) {
			Grid {
				GridRow(bottomPadding: 5) {
					Label("Braille Translation:")
					PopupButton {
						MenuItem("English (Unified)")
						MenuItem("United States")
					}
				}
				GridRow {
					Grid.EmptyCell()
					CheckBox("Show Contracted Braille")
						.bindOnOffState(self.showContractedBraille)
				}
				GridRow(bottomPadding: 5) {
					Grid.EmptyCell()
					CheckBox("Show Eight Dot Braille")
						.bindOnOffState(self.showEightDotBraille)
				}
				GridRow {
					Label("Status Cells:")
					CheckBox("Show General Display Status")
				}
				GridRow(bottomPadding: 5) {
					Grid.EmptyCell()
					CheckBox("Show Text Style")
						.bindElement(self.showTextStyleBinder)
				}
				GridRow(mergeCells: [0 ... 1]) {
					CheckBox("Show alert messages for duration")
						.bindElement(self.showAlertBinder)
					Grid.EmptyCell()
				}
			}
			.columnFormatting(xPlacement: .trailing, trailingPadding: 5, atColumn: 0)
			.cellFormatting(xPlacement: .none, atRowIndex: 5, columnIndex: 0)

			.addingCellContraints(atRowIndex: 5, columnIndex: 0) { [weak self] in
				guard let `self` = self,
						let showTextStyle = self.showTextStyleBinder.view,
						let showAlert = self.showAlertBinder.view else { return [] }
				return [showAlert.centerXAnchor.constraint(equalTo: showTextStyle.leadingAnchor)]
			}

			.applyRecursively { element in
				_ = element
					.border(width: 0.5, color: NSColor.gridColor)
					.backgroundColor(NSColor.textColor.withAlphaComponent(0.1))
			}
		}
}
