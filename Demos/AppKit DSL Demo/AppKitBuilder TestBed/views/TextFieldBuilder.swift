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

	let editText = ValueBinder("Text goes here...")

	let dynFont1 = DynamicFontService.shared.add(.monospaced.size(11).weight(.ultraLight))
	let dynFont2 = DynamicFontService.shared.add(.body.size(16).weight(.light))

	lazy var newAttr: Element = {
		if #available(macOS 12, *) {
			var attributes = AttributeContainer()
			attributes.link = URL(string: "https://github.com/dagronf/DSFAppKitBuilder")
			let link = AttributedString("This is my link", attributes: attributes)
			var string = AttributedString("A DSL-style declarative UI generator: ")
			string.append(link)
			return Label(string).containsClickableLinks(true)
		} else {
			// Fallback on earlier versions
			return Label("asdfasdf")
		}
	}()

	lazy var body: Element = {
		VStack(spacing: 12, alignment: .leading) {
			FakeBox("Dynamic") {
				VStack(alignment: .leading) {
					Slider(DynamicFontService.shared.currentScale, range: 0.25 ... 4.0)
						.width(250)
					Label("This is the title")
						.dynamicFont(.title1)
					Label("Whooooo!")
						.dynamicFont(.body)
					Button(title: "Press me!", bezelStyle: .texturedSquare)
						.dynamicFont(.body)
					ComboButton(style: .split, "Whooo!", menu: nil)
						.dynamicFont(.label)
				}
			}
			.dynamicFont(.label)

			FakeBox("Labels") {
				VStack(alignment: .leading) {
					newAttr
					Link(title: "DSFAppKitBuilder link", url: URL(string: "https://github.com/dagronf/DSFAppKitBuilder")!)
						.font(.body.weight(.bold))
					Link(
						title: "DSFAppKitBuilder link",
						url: URL(string: "https://github.com/dagronf/DSFAppKitBuilder")!,
						underlineStyle: .single
					)
					.toolTip("A link that is exciting!")
				}
			}

			FakeBox("Label with padding") {
				Flow {
					Label("Label with no padding")
						.dynamicFont(.system)
						.backgroundColor(.systemBlue)
					Label("Label with 8 padding")
						.dynamicFont(.system)
						.labelPadding(8)
						.backgroundColor(.systemBlue)
					Label("Label with 16 padding")
						.dynamicFont(.system)
						.labelPadding(16)
						.backgroundColor(.systemBlue)
					Label("Label with leading padding")
						.dynamicFont(.system)
						.labelPadding(NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 0))
						.horizontalCompressionResistancePriority(.defaultLow)
						.horizontalHuggingPriority(999)
						.backgroundColor(.systemBlue)
				}
			}
			.dynamicFont(.system)
			HDivider()

			FakeBox("Label with wrapping/truncation") {
				VStack(alignment: .leading) {
					Label("Wrapping").font(.body.bold())
					Label(dummyText)
						.labelPadding(3)
						.applyStyle(Label.Styling.multiline)
						.border(width: 0.5, color: .systemRed)
						.dynamicFont(dynFont1)
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
						.dynamicFont(dynFont2)
						.labelPadding(NSEdgeInsets(top: 2, left: 48, bottom: 2, right: 4))
						.applyStyle(Label.Styling.Multiline(maximumNumberOfLines: 3))
						.border(width: 0.5, color: .systemGreen)
				}
				.hugging(h: 10)
			}
			HDivider()
			Grid {
				GridRow(rowAlignment: .firstBaseline) {
					Label("String value").dynamicFont(.system)
					TextField(stringValue).dynamicFont(.system)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label("Double value").dynamicFont(.system)
					NumberField(doubleValue, numberFormatter: doubleFormatter).dynamicFont(.system)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label("Int value").dynamicFont(.system)
					NumberField(intValue, numberFormatter: intFormatter).dynamicFont(.system)
				}
			}
			.columnFormatting(xPlacement: .trailing, atColumn: 0)

			HDivider()

			FakeBox("TextField with padding") {
				VStack(alignment: .leading) {
					Grid {
						GridRow(rowAlignment: .firstBaseline) {
							Label("[4, 4, 4, 4]").dynamicFont(.system)
							TextField(editText)
								.labelPadding(NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
								.dynamicFont(.system)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("[10, 25, 6, 40]").dynamicFont(.system)
							TextField(editText)
								.labelPadding(NSEdgeInsets(top: 10, left: 25, bottom: 6, right: 40))
								.dynamicFont(.body.size(16).weight(.light).italic())
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label("[0, 0, 0, 0]").dynamicFont(.system)
							TextField(editText).dynamicFont(.system)
						}
					}
					.columnFormatting(xPlacement: .trailing, atColumn: 0)
				}
			}

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
				DSFAppKitBuilder.EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
