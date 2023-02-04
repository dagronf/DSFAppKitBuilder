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
	var title: String { "Fonts" }
	func build() -> ElementController {
		FontBuilderController()
	}
}

class FontBuilderController: ElementController {

	fileprivate let _sampleText = "Sphinx of black quartz judge my vow 19.330"

	lazy var body: Element = {
		VStack(alignment: .leading) {
			HStack {
				Label("Plain text").font(.body)
				Label("Plain text").font(.body.size(14))
				Label("Plain text").font(.body.size(16))
				Label("Plain text").font(.body.size(18))
				Label("Plain text").font(.body.size(24))
			}
			HDivider()
			HStack {
				Label("Plain text").font(.body)
				VDivider()
				Label("Bold text").font(.body.bold())
				VDivider()
				Label("Italic text").font(.body.italic())
				VDivider()
				Label("Bold Italic text").font(.body.bold().italic())
				VDivider()
				Label("Heavy text").font(.body.weight(.heavy))
				VDivider()
				Label("Black Italic text").font(.body.weight(.black).italic())
			}
			HStack {
				Label("Monospaced").font(.monospaced)
				VDivider()
				Label("Monospaced Bold").font(.monospaced.bold())
			}

			HStack {
				Label("standard").font(.title2)
				VDivider()
				Label("expanded").font(.title2.expanded())
				VDivider()
				Label("condensed").font(.title2.condensed())
			}
			HDivider()
			Grid {
				GridRow(rowAlignment: .firstBaseline) {
					Label("Style").font(.title3.bold()).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
					Label("Preview").font(.title3.bold()).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".body").font(.monospaced)
					Label(_sampleText).font(.body).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".callout").font(.monospaced)
					Label(_sampleText).font(.caption1).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".caption1").font(.monospaced)
					Label(_sampleText).font(.caption1).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".footnote").font(.monospaced)
					Label(_sampleText).font(.footnote).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".headline").font(.monospaced)
					Label(_sampleText).font(.headline).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".subheadline").font(.monospaced)
					Label(_sampleText).font(.subheadline).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".system").font(.monospaced)
					Label(_sampleText).font(.system).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".largeTitle").font(.monospaced)
					Label(_sampleText).font(.largeTitle).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".title1").font(.monospaced)
					Label(_sampleText).font(.title1).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".title2").font(.monospaced)
					Label(_sampleText).font(.title2).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".title3").font(.monospaced)
					Label(_sampleText).font(.title3).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".monospacedDigit").font(.monospaced)
					Label(_sampleText).font(.monospacedDigit).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".monospaced").font(.monospaced)
					Label(_sampleText).font(.monospaced).truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
				}
			}
			HDivider()
			HStack {
				Button(title: "Pressable!")
				Button(title: "Pressable!").font(.system.bold())
				Button(title: "Pressable!").font(.system.italic())
				VDivider()
				CheckBox("Checkbox!").font(.system.italic())
				CheckBox("Checkbox!").font(.system.bold())
			}
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
