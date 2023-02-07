//
//  DisclosureViewBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

public class DisclosureViewBuilder: ViewTestBed {
	var title: String { String.localized("Disclosure View/Group") }
	var type: String { "DisclosureView/DisclosureGroup" }
	var description: String { String.localized("A disclosure view consists of a label to identify the contents, and a control to show and hide the contents. Showing the contents puts the disclosure group into the “expanded” state, and hiding them makes the disclosure view 'collapsed'.") }
	func build() -> ElementController {
		DisclosureViewController()
	}
}

class DisclosureViewController: ElementController {

	let __onOffBinder1 = ValueBinder(true)
	let __onOffBinder2 = ValueBinder(false)
	let __headerFont = AKBFont.title3.bold()

	lazy var body: Element = {
		VStack(alignment: .leading) {
			VStack(alignment: .leading) {
				VStack(alignment: .leading) {
					Label("Basic control").font(__headerFont)
					DisclosureView(title: "Format") {
						HStack {
							Label("Format style!")
							EmptyView()
							Toggle()
						}
					}
					.backgroundColor(NSColor.systemPurple.withAlphaComponent(0.2))

					DisclosureView(title: "Style", initiallyExpanded: false) {
						VStack {
							HStack {
								Label("Format style!")
								EmptyView()
								Toggle()
							}
							HStack {
								Label("Values")
								EmptyView()
								TextField().width(60)
								TextField().width(60)
								TextField().width(60)
							}
							.hugging(h: 10)
						}
					}
					.backgroundColor(NSColor.systemTeal.withAlphaComponent(0.2))
				}
				.hugging(h: 10)
			}
			.padding(8)
			.border(width: 1, color: NSColor.quaternaryLabelColor)
			.cornerRadius(8)

			VStack(alignment: .leading) {
				HStack {
					Label("Basic control with header").font(__headerFont)
						.horizontalCompressionResistancePriority(.defaultLow)
						.truncatesLastVisibleLine(true)
						.lineBreakMode(.byTruncatingHead)
					EmptyView()
					Label("first:")
					Toggle()
						.bindOnOff(__onOffBinder1)
					Label("second:")
					Toggle()
						.bindOnOff(__onOffBinder2)
					Button(title: "toggle", bezelStyle: .roundRect) { [weak self] _ in
						guard let `self` = self else { return }
						self.__onOffBinder1.wrappedValue.toggle()
						self.__onOffBinder2.wrappedValue.toggle()
					}

				}
				DisclosureView(title: "Text Format", headerHeight: 28, header: {
					HStack {
						Label("Spacing:")
						TextField().width(60).controlSize(.small).roundedBezel()
					}
				}) {
					HStack {
						Label("Format style!")
						EmptyView()
						Toggle()
					}
				}
				.bindIsExpanded(__onOffBinder1)
				.backgroundColor(NSColor.systemPink.withAlphaComponent(0.2))
				.cornerRadius(4)

				DisclosureView(title: "Spacing", headerHeight: 28, initiallyExpanded: false, header: {
					Button(title: "Reset", bezelStyle: .roundRect).controlSize(.small)
				}) {
					HStack {
						Label("Format style!")
						EmptyView()
						Toggle()
					}
				}
				.bindIsExpanded(__onOffBinder2)
				.backgroundColor(NSColor.systemGreen.withAlphaComponent(0.2))
				.cornerRadius(4)
			}
			.hugging(h: 10)
			.padding(8)
			.border(width: 1, color: NSColor.quaternaryLabelColor)
			.cornerRadius(8)

			HDivider()

			Label("Disclosure Group").font(__headerFont)
			self.otherContent

			EmptyView()
		}
	}()

	let firstSize = ValueBinder(1.0)
	let firstVisible = ValueBinder(false)
	let firstSizeFormatter = NumberFormatter {
		$0.minimumFractionDigits = 0
		$0.maximumFractionDigits = 1
	}

	private lazy var otherContent: Element = {
		DisclosureGroup {
			DisclosureView(title: "Spacing", isExpandedBinder: firstVisible, header: {
				Button(title: "Reset").controlSize(.small)
			}) {
				VStack {
					HStack {
						PopupButton {
							MenuItem("Lines")
							MenuItem("At Least")
							MenuItem("Exactly")
							MenuItem("Between")
						}
						EmptyView()
						TextField("one")
							.isEnabled(false)
							.bindValue(firstSize, formatter: firstSizeFormatter)
							.width(60)
						Stepper(range: 0.1 ... 10.0, increment: 0.1)
							.valueWraps(false)
							.bindValue(firstSize)
					}
					HStack {
						Label("Before Paragraph")
						EmptyView()
						TextField("one")
							.width(60)
						Stepper()
					}
					HStack {
						Label("After Paragraph")
						EmptyView()
						TextField("one")
							.width(60)
						Stepper()
							.horizontalHuggingPriority(999)
					}
				}
			}
			.disclosureTooltip("Formatting disclosure view")

			DisclosureView(title: "Bullets & Lists", initiallyExpanded: true) {
				VStack {
					HStack {
						Label("Slidey!")
							.horizontalHuggingPriority(.init(10))
						Slider(range: 0 ... 100, value: 65)
					}
					HStack {
						Label("Activatey?")
							.horizontalHuggingPriority(.init(10))
						Toggle()
					}
				}
			}
		}
		.horizontalHuggingPriority(1)
		.padding(8)
		.backgroundColor(NSColor.systemYellow.withAlphaComponent(0.05))
	}()

}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct DisclosureViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			DisclosureViewBuilder().build().body
				.SwiftUIPreview()
		}
	}
}
#endif
