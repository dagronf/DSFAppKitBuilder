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

public class ListBuilder: ViewTestBed {
	var title: String { String.localized("List Builder") }
	var type: String { "List" }
	var showContentInScroll: Bool { true }
	var description: String { String.localized("An element that builds a stack from the contents of an array") }
	func build() -> ElementController {
		ListBuilderController()
	}
}

class ListBuilderController: ElementController {
	let items = ValueBinder([0,1,2,3,4,5,6,7,8,9])
	let showSheet = ValueBinder(false)
	var showItem: Int = 0

	var listSize = 6
	func rebuildSequence() {
		let n = (0 ..< listSize).map { _ in Int.random(in: 0...9) }
		self.items.wrappedValue = n
	}

	init() {
		self.rebuildSequence()
	}

	lazy var body: Element = {
		Group(layoutType: .center) {
			VStack {

				HStack {
					Button(title: "Random") { [weak self] _ in
						self?.rebuildSequence()
					}
					Button(title: "Add 1") { [weak self] _ in
						guard let `self` = self else { return }
						self.listSize += 1
						self.rebuildSequence()
					}
					Button(title: "Remove 1") { [weak self] _ in
						guard let `self` = self else { return }
						self.listSize += (self.listSize > 1) ? -1 : 0
						self.rebuildSequence()
					}
				}
				.padding(4)
				.backgroundColor(NSColor.secondaryLabelColor)

				List(self.items) { item in
					VStack {
						HStack {
							DSFAppKitBuilder.Shape(path: CGPath(ellipseIn: CGRect(x: 1, y: 1, width: 31, height: 31), transform: nil))
								.fillColor(CGColor.random())
								.strokeColor(NSColor.textColor.cgColor)
								.lineWidth(0.5)
								.shadow(radius: 1, offset: CGSize(width: 0.5, height: -1))
								.size(width: 33, height: 33)
							VStack(spacing: 0, alignment: .leading) {
								Label("Noodle \(item)")
									.horizontalHuggingPriority(10)
									.font(.title2)
								Label("Description")
									.textColor(NSColor.disabledControlTextColor)
									.font(.caption1.italic())
									.horizontalHuggingPriority(10)
							}
							EmptyView()
								.width(100)
							Button(title: "Show") { [weak self] _ in
								Swift.print("Pressed \(item)")
								self?.showItem = item
								self?.showSheet.wrappedValue = true
							}
						}
						HDivider()
					}
				}
			}
			.hugging(h: 10)
		}
		.alert(isVisible: self.showSheet, alertBuilder: {
			let a = NSAlert()
			a.messageText = "Noodle \(self.showItem)"
			return a
		}, onDismissed: { response in

		})
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ListBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			ListBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
