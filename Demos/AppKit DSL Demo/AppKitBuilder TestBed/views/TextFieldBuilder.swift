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

	lazy var body: Element = {
		VStack(spacing: 12, alignment: .leading) {
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
