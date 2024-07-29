//
//  BlankTemplateBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 17/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders
import DSFPagerControl

public class PagerBuilder: ViewTestBed {
	var title: String { String.localized("Pager") }
	var type: String { "A Pager control" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("A control that displays an optionally selectable/changable page indicator") }
	func build() -> ElementController {
		PagerBuilderController()
	}
}

class PagerBuilderController: ElementController {
	@ValueBinding var selectedPage: Int = 1
	@ValueBinding var selectedPage2: Int = 3

	@ValueBinding var pageCount: Int = 4
	@ValueBinding var pageCountSelection: Int = 0

	@ValueBinding var pagerEnabled: Bool = true

	lazy var body: Element = {
		Group(layoutType: .center) {
			VStack {
				Box("No user interactions") {
					HStack {
						Button(title: "<") { [weak self] _ in
							guard let `self` = self else { return }
							selectedPage = max(0, selectedPage - 1)
						}
						.bindIsEnabled($selectedPage.transform { $0 != 0 })

						Pager(pageCount: 10, selectedPage: $selectedPage)
							.didChangeToPage { newPage in
								Swift.print("Changed page to \(newPage)")
							}

						Button(title: ">") { [weak self] _ in
							guard let `self` = self else { return }
							selectedPage = min(9, selectedPage + 1)
						}
						.bindIsEnabled($selectedPage.transform { $0 != 9 })
					}
					.padding(4)
				}

				HStack {
					VStack {
						Box("Allows keyboard interactions") {
							Pager(
								pageCount: 7,
								selectedPage: $selectedPage2,
								allowsKeyboardInteration: true
							)
							.padding(4)
						}
						.width(250)
						Box("Allows mouse interactions") {
							HStack {
								Pager(
									pageCount: 7,
									selectedPage: $selectedPage2,
									allowsMouseInteration: true,
									selectedColor: .systemYellow,
									unselectedColor: .systemYellow.withAlphaComponent(0.2)
								)
								.bindIsEnabled($pagerEnabled)
								CheckBox("Enabled")
									.bindOnOffState($pagerEnabled)
									.controlSize(.small)
							}
							.padding(4)
						}
						.width(250)
						Box("Allows both keyboard and mouse") {
							Pager(
								indicatorShape: DSFPagerControl.ThinHorizontalPillShape(),
								pageCount: 7,
								selectedPage: $selectedPage2,
								allowsKeyboardInteration: true,
								allowsMouseInteration: true,
								bordered: true
							)
							.padding(4)
						}
						.width(250)
					}

					Box {
						Pager(
							indicatorShape: DSFPagerControl.VerticalIndicatorShape(),
							pageCount: 7,
							selectedPage: $selectedPage2,
							allowsKeyboardInteration: true,
							allowsMouseInteration: true
						)
						.didChangeToPage { newPage in
							Swift.print("Vertical changed page to \(newPage)")
						}
						.padding(4)
					}
				}

				Box("Variable page counts") {
					VStack {
						Pager(
							pageCount: 4,
							selectedPage: $pageCountSelection,
							allowsKeyboardInteration: true,
							allowsMouseInteration: true
						)
						.bindPageCount($pageCount)
						.didChangeToPage { newPage in
							Swift.print("variable page pager changed page to \(newPage)")
						}
						.padding(4)

						HStack {
							Button(title: "Add page") { [weak self] _ in
								self?.pageCount += 1
							}
							Button(title: "Remove page") { [weak self] _ in
								guard let `self` = self else { return }
								self.pageCount = max(self.pageCount - 1, 1)
							}
						}
					}
				}
			}
		}
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct PagerBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			PagerBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
