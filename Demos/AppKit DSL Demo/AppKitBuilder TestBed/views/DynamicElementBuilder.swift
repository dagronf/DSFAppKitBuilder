//
//  DynamicElementBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 6/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class DynamicElementBuilder: ViewTestBed {
	var title: String { String.localized("Dynamic Element") }
	var type: String { "DynamicElement" }
	var description: String { String.localized("An element with a hot-swappable child element") }
	func build() -> ElementController {
		DynamicElementBuilderController()
	}
}

class DynamicElementBuilderController: ElementController {
	private let elementBinder = ValueBinder<Element?>(nil)

	lazy var body: Element = {
		VStack(spacing: 16, alignment: .leading) {
			HStack {
				Label("Choose a view:")
				PopupButton {
					MenuItem("None")
					MenuItem("Text Field")
					MenuItem("Button")
					MenuItem("Custom View")
				}
				.onChange { [weak self] newElement in
					guard let `self` = self else { return }
					if newElement == 0 {
						self.elementBinder.wrappedValue = nil
					}
					else if newElement == 1 {
						self.elementBinder.wrappedValue = TextField("This is a text field")
					}
					else if newElement == 2 {
						self.elementBinder.wrappedValue = Button(title: "My button!")
					}
					else if newElement == 3 {
						self.elementBinder.wrappedValue = VStack {
							DisclosureView(title: "Format (default on)") {
								VStack {
									HStack {
										Label("Format style!")
										EmptyView()
										Toggle()
									}
									ImageView(NSImage(named: "status-bar-icon"))
										.scaling(.scaleProportionallyUpOrDown)
										.height(50)
										.horizontalHuggingPriority(1)
								}
								.hugging(h: 10)
							}
						}
						.hugging(h: 10)
					}
				}
			}
			DynamicElement(elementBinder, visualEffect: .init(material: .sidebar))
				.border(width: 0.5, color: NSColor.systemRed)

			EmptyView()
		}
		.hugging(h: 10)
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ElementViewBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				DynamicElementBuilder().build().body
				DSFAppKitBuilder.EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
