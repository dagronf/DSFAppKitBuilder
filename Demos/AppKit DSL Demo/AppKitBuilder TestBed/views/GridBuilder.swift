//
//  GridBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

public class GridBuilder: ViewTestBed {
	var title: String { String.localized("Grid") }
	var type: String { "Grid" }
	var description: String { String.localized("A grid control") }
	func build() -> ElementController {
		GridBuilderController()
	}
}

class GridBuilderController: ElementController {
	let showTextStyleBinder = ElementBinder()
	let showAlertBinder = ElementBinder()

	let showContractedBraille = ValueBinder(false)
	let showEightDotBraille = ValueBinder(false)

	deinit {
		Swift.print("GridBuilderController: deinit")
	}

	lazy var body: Element = {
		VStack(spacing: 16) {
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
					guard
						let `self` = self,
						let showTextStyle = self.showTextStyleBinder.view,
						let showAlert = self.showAlertBinder.view
					else {
						return []
					}
					return [showAlert.centerXAnchor.constraint(equalTo: showTextStyle.leadingAnchor)]
				}

				.applyRecursively { element in
					_ = element
						.border(width: 0.5, color: NSColor.systemRed)
					//					.backgroundColor(NSColor.textColor.withAlphaComponent(0.1))
				}
			}
		}
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct GridBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				GridBuilder().build().body
				DSFAppKitBuilder.EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
