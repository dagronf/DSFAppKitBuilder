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
		Group(layoutType: .pinEdges) {
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
					EmptyView()
				}
				.padding(4)
				.backgroundColor(NSColor.black.withAlphaComponent(0.1))

				List(self.items) { [weak self] item in
					VStack {
						HStack {
							DSFAppKitBuilder.Shape.Circle(32)
								.fillColor(CGColor.random())
								.strokeColor(NSColor.textColor)
								.lineWidth(0.5)
								.shadow(radius: 1, offset: CGSize(width: 0.5, height: -1))
								.onClickGesture {
									Swift.print("clicked \(item)!")
								}
							VStack(spacing: 0, alignment: .leading) {
								Label("Noodle \(item)")
									.horizontalHuggingPriority(10)
									.dynamicFont(.title2)
								Label("Description")
									.textColor(NSColor.disabledControlTextColor)
									.dynamicFont(.caption1.italic())
									.horizontalHuggingPriority(10)
							}
							EmptyView()
							Button(title: "Show") { [weak self] _ in
								guard let `self` = self else { return }
								Swift.print("Pressed \(item)")
								self.showItem = item
								self.showSheet.wrappedValue = true
							}
						}
						HDivider()
					}
				}
				.edgeInsets(NSEdgeInsets(edgeInset: 12))
			}
		}
		.alert(isVisible: self.showSheet, alertBuilder: { [weak self] in
			guard let `self` = self else { return NSAlert() }
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
