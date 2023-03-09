//
//  Font.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder

public class FontBuilder: ViewTestBed {
	var title: String { String.localized("Font Styles") }
	var type: String { "" }
	var description: String { String.localized("The built-in font styles") }
	func build() -> ElementController {
		FontBuilderController()
	}
}

class FontBuilderController: ElementController {

	fileprivate let _sampleText = "Sphinx of black quartz judge my vow 19.330"

	class LayoutStyle: DSFAppKitBuilder.LabelStyle {
		static let shared = LayoutStyle()
		func apply(_ labelElement: DSFAppKitBuilder.Label) -> DSFAppKitBuilder.Label {
			labelElement
				.truncatesLastVisibleLine(true)
				.lineBreakMode(.byTruncatingTail)
				.horizontalHuggingPriority(.init(10))
				.horizontalCompressionResistancePriority(.init(10))
		}
	}

	lazy var body: Element = {
		VStack(alignment: .leading) {
			Flow(minimumInteritemSpacing: 4) {
				Label("Plain text (default)").dynamicFont(.body)
				Label("Plain text (14)").dynamicFont(.body.size(14))
				Label("Plain text (16)").dynamicFont(.body.size(16))
				Label("Plain text (18)").dynamicFont(.body.size(18))
				Label("Plain text (24)").dynamicFont(.body.size(24))
			}

			HDivider()

			HStack {
				Label(".system").dynamicFont(.system)
				VDivider()
				Label(".systemSmall").dynamicFont(.systemSmall)
				VDivider()
				Label(".label").dynamicFont(.label)
			}
			.hugging(h: 10)

			HDivider()

			Flow(minimumInteritemSpacing: 4) {
				Label("Plain text").dynamicFont(.body)
				VDivider().height(16)
				Label("Bold text").dynamicFont(.body.bold())
				VDivider().height(16)
				Label("Italic text").dynamicFont(.body.italic())
				VDivider().height(16)
				Label("Bold Italic text").dynamicFont(.body.bold().italic())
				VDivider().height(16)
				Label("Heavy text").dynamicFont(.body.weight(.heavy))
				VDivider().height(16)
				Label("Black Italic text").dynamicFont(.body.weight(.black).italic())
			}

			HStack {
				Label("Monospaced").dynamicFont(.monospaced)
				VDivider()
				Label("Monospaced Bold").dynamicFont(.monospaced.bold())
			}
			.hugging(h: 10)

			HStack {
				Label("standard").dynamicFont(.title2)
				VDivider()
				Label("expanded").dynamicFont(.title2.expanded())
				VDivider()
				Label("condensed").dynamicFont(.title2.condensed())
			}
			.hugging(h: 10)

			HDivider()

			Grid {
				GridRow(rowAlignment: .firstBaseline) {
					Label("Style").font(.title3.bold()).applyStyle(Label.Styling.truncatingTail)
					Label("Preview").font(.title3.bold()).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".body").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.body).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".callout").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.caption1).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".caption1").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.caption1).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".caption2").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.caption2).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".footnote").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.footnote).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".headline").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.headline).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".subheadline").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.subheadline).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".system").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.system).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".largeTitle").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.largeTitle).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".title1").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.title1).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".title2").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.title2).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".title3").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.title3).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".monospacedDigit").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.monospacedDigit).applyStyle(LayoutStyle.shared)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".monospaced").dynamicFont(.monospaced)
					Label(_sampleText).dynamicFont(.monospaced).applyStyle(LayoutStyle.shared)
				}
			}
			.horizontalHuggingPriority(10)

			HDivider()
			
			HStack {
				Button(title: "Pressable!")
				Button(title: "Pressable!").dynamicFont(.system.bold())
				Button(title: "Pressable!").dynamicFont(.system.italic())
				VDivider()
				CheckBox("Checkbox!").dynamicFont(.system.italic())
				CheckBox("Checkbox!").dynamicFont(.system.bold())
			}
			.hugging(h: 10)
		}
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct FontBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				FontBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
