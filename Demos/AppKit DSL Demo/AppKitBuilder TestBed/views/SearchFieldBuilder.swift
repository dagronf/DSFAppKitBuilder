//
//  SearchFieldBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 6/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders

class SearchFieldBuilder: ViewTestBed {
	var title: String { String.localized("Search field") }
	var type: String { "SearchField" }
	var description: String { String.localized("Element for displaying a search field") }
	func build() -> ElementController {
		SearchFieldBuilderController()
	}
}

class SearchFieldBuilderController: ElementController {

	let __searchText = ValueBinder("")
	let __searchSubmittedText = ValueBinder("")
	let __searchText2 = ValueBinder("")
	let __searchSubmittedText2 = ValueBinder("")

	lazy var body: Element = {
		VStack(spacing: 16, alignment: .leading) {
			Box("Value binding updates") {
				VStack(alignment: .leading) {
					SearchField()
						.bindSearchTerm(__searchText, updateType: .all)
						.onSubmit { [weak self] newValue in
							self?.__searchSubmittedText.wrappedValue = newValue
						}
					HStack {
						Label("Search text:")
						TextField()
							.bindText(__searchText)
					}

					HStack {
						Label("Last submit:")
						Label()
							.bindLabel(__searchSubmittedText.stringValue(emptyPlaceholderString: "<empty>"))
							.horizontalHuggingPriority(20)
					}
				}
			}
			.titleFont(.headline)
			.horizontalHuggingPriority(.init(10))

			Box("Binding update on submit only") {
				VStack(alignment: .leading) {
					SearchField()
						.bindSearchTerm(__searchText2, updateType: .submitOnly)
						.onSubmit { [weak self] newValue in
							self?.__searchSubmittedText2.wrappedValue = newValue
						}
						.horizontalHuggingPriority(10)

					HStack {
						Label("Search text:")
						TextField()
							.bindText(__searchText2)
							.horizontalHuggingPriority(10)
					}
					.hugging(h: 10)

					HStack {
						Label("Last submit:")
						Label()
							.bindLabel(__searchSubmittedText2.stringValue(emptyPlaceholderString: "<empty>"))
							.horizontalHuggingPriority(10)
					}
					.hugging(h: 10)
				}
				.hugging(h: 10)
			}
			.titleFont(.headline)
			.horizontalHuggingPriority(.init(10))

			HDivider()
			Grid {
				GridRow(rowAlignment: .firstBaseline) {
					Label("Show placeholder text:")
						.font(.title3.weight(.medium))
					SearchField(placeholderText: "Type something…")
						.font(.title3.weight(.medium))
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label("Set initial value:")
						.font(.title3.weight(.medium))
					SearchField(
						initialSearchTerm: "caterpillar",
						placeholderText: "Search for something meaningful…"
					)
					.font(.title3.weight(.medium))
				}
			}
			.columnFormatting(xPlacement: .trailing, atColumn: 0)
		}
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct SearchFieldBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				SearchFieldBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
