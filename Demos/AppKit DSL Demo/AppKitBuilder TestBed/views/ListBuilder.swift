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
	lazy var body: Element = {
		Group(layoutType: .center) {
			VStack {
				List(self.items) { item in
					HStack {
						DSFAppKitBuilder.Shape(path: CGPath(ellipseIn: CGRect(origin: .zero, size: .init(width: 32, height: 32)), transform: nil))
							.fillColor(CGColor.random())
							.size(width: 32, height: 32)
						VStack(alignment: .leading) {
							Label("Noodle \(item)")
								.font(.title2)
							Label("Description")
								.font(.caption1)
						}
						Button(title: "Do!") { [weak self] _ in
							Swift.print("Pressed \(item)")
						}
					}
				}
				Button(title: "Generate Random Numbers") { [weak self] _ in
					let n = (0 ..< 10).map { _ in Int.random(in: 0...9) }
					self?.items.wrappedValue = n
				}
			}
		}
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
