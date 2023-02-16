//
//  TextFieldBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 14/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class TextFieldBuilder: ViewTestBed {
	var title: String { String.localized("Text/Number Fields") }
	var type: String { "TextField/NumberField" }
	var description: String { String.localized("An (optionally) editable text field") }
	func build() -> ElementController {
		TextFieldBuilderController()
	}
}

class TextFieldBuilderController: ElementController {
	let stringValue = ValueBinder("Sample text")
	let doubleValue = ValueBinder(12.3456)
	let doubleFormatter = NumberFormatter {
		$0.allowsFloats = true
		$0.minimumFractionDigits = 0
		$0.maximumFractionDigits = 4
	}

	let intValue = ValueBinder(9943)
	let intFormatter = NumberFormatter {
		$0.minimumFractionDigits = 0
		$0.maximumFractionDigits = 0
	}

	let dummyText = "So I decided to make a SwiftUI-style builder DSL for AppKit views. It has certainly made round-trip times faster for the projects I have that use it. You can even use SwiftUI to preview your DSFAppKitBuilder views if you're targeting 10.15 and later."
	let dummyText2 = "So I decided to make a SwiftUI-style builder DSL for AppKit views. It has certainly made round-trip times faster for the projects I have that use it."

	lazy var body: Element = {
		VStack(spacing: 12, alignment: .leading) {
			FakeBox("Label with padding") {
				Flow {
					Label("Label with no padding")
						.backgroundColor(.systemBlue)
					Label("Label with 8 padding")
						.labelPadding(8)
						.backgroundColor(.systemBlue)
					Label("Label with 16 padding")
						.labelPadding(16)
						.backgroundColor(.systemBlue)
					Label("Label with leading padding")
						.labelPadding(NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
						.horizontalCompressionResistancePriority(.defaultLow)
						.horizontalHuggingPriority(999)
						.backgroundColor(.systemBlue)
				}
			}
			HDivider()

			FakeBox("Label with wrapping/truncation") {
				VStack(alignment: .leading) {
					Label("Wrapping").font(.body.bold())
					Label(dummyText)
						.labelPadding(3)
						.applyStyle(Label.Styling.multiline)
						.border(width: 0.5, color: .systemRed)
						.font(.monospaced.size(11).weight(.ultraLight))
					HDivider()
					Label("Single-line truncation").font(.body.bold())
					Grid {
						GridRow(rowAlignment: .firstBaseline) {
							Label("tail:").font(.body.weight(.medium))
							Label(dummyText2)
								.labelPadding(2)
								.truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingTail).horizontalCompressionResistancePriority(.init(10))
								.border(width: 0.5, color: .systemBlue)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("head:").font(.body.weight(.medium))
							Label(dummyText2)
								.labelPadding(2)
								.truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingHead).horizontalCompressionResistancePriority(.init(10))
								.border(width: 0.5, color: .systemBlue)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("middle:").font(.body.weight(.medium))
							Label(dummyText2)
								.labelPadding(2)
								.truncatesLastVisibleLine(true).lineBreakMode(.byTruncatingMiddle).horizontalCompressionResistancePriority(.init(10))
								.border(width: 0.5, color: .systemBlue)
						}
					}
					.columnFormatting(xPlacement: .trailing, atColumn: 0)
					HDivider()
					Label("Multi-line truncation, uneven padding, fixed max rows").font(.body.bold())
					Label(dummyText)
						.font(.body.size(16).weight(.light))
						.labelPadding(NSEdgeInsets(top: 2, left: 48, bottom: 2, right: 4))
						.applyStyle(Label.Styling.Multiline(maximumNumberOfLines: 3))
						.border(width: 0.5, color: .systemGreen)
				}
				.hugging(h: 10)
			}

			HDivider()
			Grid {
				GridRow(rowAlignment: .firstBaseline) {
					Label("String value")
					TextField(stringValue)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label("Double value")
					NumberField(doubleValue, numberFormatter: doubleFormatter)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label("Int value")
					NumberField(intValue, numberFormatter: intFormatter)
				}
			}
			.columnFormatting(xPlacement: .trailing, atColumn: 0)

			EmptyView()
		}
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct TextFieldBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				TextFieldBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
