//
//  PanelStyleBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 17/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

public class PanelStyleBuilder: ViewTestBed {
	var title: String { String.localized("Panel style demo") }
	var type: String { "" }
	var showContentInScroll: Bool { true }
	var description: String { String.localized("A demo of building a panel-style interface (taken from RetroBatch (https://flyingmeat.com/retrobatch/)") }
	func build() -> ElementController {
		PanelStyleBuilderController()
	}
}

class PanelStyleBuilderController: ElementController {
	let shouldWrite = ValueBinder(true)
	let openFolderWhenComplete = ValueBinder(true)
	let overwriteExisting = ValueBinder(false)
	let writeBackToOriginalImages = ValueBinder(false)
	let askForOutputFolder = ValueBinder(false)

	let outputEncoding = ValueBinder(0)

	let systemMenu = ValueBinder(0) { x in
		Swift.print("value - \(x)")
	}

	let filenameDefinition = ValueBinder<[String]>([
		"File Name",
		"@2x",
	])

	let qualityValue = ValueBinder(0.75)
	let percentFormatter = NumberFormatter {
		$0.numberStyle = .percent
		$0.maximumFractionDigits = 2
	}

	let titleFont = AKBFont.body.weight(.medium).size(13)

	let outFolder = ValueBinder(FileManager.default.homeDirectoryForCurrentUser)

	lazy var body: Element = {
		VStack(alignment: .leading) {
			HStack {
				Label("Write Images").font(.title3.bold())
				EmptyView()
				CheckBox()
					.hidesTitle(true)
					.bindOnOffState(self.shouldWrite)
					.controlSize(.large)
			}
			Grid {
				GridRow(rowAlignment: .firstBaseline) {
					Label(String.localized("Folder:")).font(titleFont)
					PathControl(bindingURL: outFolder, style: .popUp)
						.horizontalHuggingPriority(1)
				}
				GridRow {
					Grid.EmptyCell()
					CheckBox(String.localized("Open folder when export finishes"))
						.bindOnOffState(openFolderWhenComplete)
						.horizontalHuggingPriority(1)
				}
				GridRow {
					Grid.EmptyCell()
					CheckBox(String.localized("Overwrite existing images"))
						.bindOnOffState(overwriteExisting)
						.horizontalHuggingPriority(1)
				}

				GridRow(topPadding: 4, rowAlignment: .firstBaseline) {
					Label(String.localized("Advanced:")).font(titleFont)
					CheckBox(String.localized("Write back to original images"))
						.bindOnOffState(writeBackToOriginalImages)
						.horizontalHuggingPriority(1)
				}
				GridRow {
					Grid.EmptyCell()
					CheckBox(String.localized("Ask for output folder when run"))
						.bindOnOffState(askForOutputFolder)
						.horizontalHuggingPriority(1)
				}

				GridRow(topPadding: 4, rowAlignment: .firstBaseline) {
					Label(String.localized("File name:")).font(titleFont)
					HStack(alignment: .top) {
						TokenField(content: filenameDefinition)
							.applyStyle(Label.Styling.multiline)
							.height(50)
							.horizontalHuggingPriority(10)
						SystemStylePopoverButton(bezelStyle: .shadowlessSquare, isBordered: false) {
							MenuItem(String.localized("item 1"))
							MenuItem(String.localized("item 2"))
						}
						.horizontalCompressionResistancePriority(.required)
						.bindSelection(systemMenu)
					}
				}

				GridRow(topPadding: 4, rowAlignment: .firstBaseline) {
					Label(String.localized("Convert to:")).font(titleFont)
					PopupButton {
						MenuItem("HEIC")
						MenuItem("JPEG")
						MenuItem("PNG")
					}
					.bindSelection(outputEncoding)
					.horizontalPriorities(hugging: 1)
				}

				GridRow(topPadding: 4, rowAlignment: .firstBaseline) {
					Label(String.localized("Quality:")).font(titleFont)
					HStack {
						Slider(qualityValue, range: 0.1 ... 1.0)
						Label(qualityValue.stringValue(using: self.percentFormatter))
							.width(40)
					}
				}

				GridRow {
					Grid.EmptyCell()
					CheckBox(String.localized("Progressive"))
						.horizontalHuggingPriority(1)
				}
				GridRow {
					Grid.EmptyCell()
					CheckBox(String.localized("Remove alpha channel if opaque"))
						.horizontalHuggingPriority(1)
				}
			}
			.columnFormatting(xPlacement: .trailing, atColumn: 0)
			.horizontalHuggingPriority(10)
			HDivider()
			EmptyView()
		}
		.hugging(h: 20)
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct PanelStyleBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			PanelStyleBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
