//
//  VisualEffectBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 6/2/2023.
//


import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class VisualEffectBuilder: ViewTestBed {
	var title: String { String.localized("Visual Effect View") }
	var type: String { "VisualEffectView" }
	var description: String { String.localized("A view Element that displays its child elements on a NSVisualEffectView") }
	func build() -> ElementController {
		VisualEffectBuilderController()
	}
}

class VisualEffectBuilderController: ElementController {
	private let elementBinder = ValueBinder<Element?>(nil)

	lazy var body: Element = {
		VStack(spacing: 16, alignment: .leading) {
			VStack(alignment: .leading) {
				Label("Available for all macOS versions").font(.title3)
				HStack {
					Box(".titlebar") {
						VisualEffectView(material: .titlebar)
							.size(width: 200, height: 50)
					}
					Box(".selection") {
						VisualEffectView(material: .selection)
							.size(width: 200, height: 50)
					}
					Box(".menu") {
						VisualEffectView(material: .menu)
							.size(width: 200, height: 50)
					}
				}

				HStack {
					Box(".popover") {
						VisualEffectView(material: .popover)
							.size(width: 200, height: 50)
					}
					Box(".sidebar") {
						VisualEffectView(material: .sidebar)
							.size(width: 200, height: 50)
					}
				}

				HDivider()

				self.buildModernEffects()

				HDivider()

				self.buildWithChildren()
			}
		}
	}()

	func buildWithChildren() -> Element {
		VStack(alignment: .leading) {
			Label("Visual Effect View with child element(s)").font(.title3)
				.horizontalHuggingPriority(10)
			VisualEffectView(material: .sidebar) {
				HStack(spacing: 4) {
					Label("Perform a search:").font(.headline)
					SearchField()
					Toggle()
				}
				.padding(8)
			}
			.border(width: 0.5, color: NSColor.quaternaryLabelColor)
		}
	}

	func buildModernEffects() -> Element {
		if #available(macOS 10.14, *) {
			return VStack(alignment: .leading) {
				Label("Available 10.14+").font(.title3)
				HStack {
					Box(".headerView") {
						VisualEffectView(material: .headerView)
							.size(width: 200, height: 50)
					}
					Box(".sheet") {
						VisualEffectView(material: .sheet)
							.size(width: 200, height: 50)
					}
					Box(".windowBackground") {
						VisualEffectView(material: .windowBackground)
							.size(width: 200, height: 50)
					}
				}

				HStack {
					Box(".hudWindow") {
						VisualEffectView(material: .hudWindow)
							.size(width: 200, height: 50)
					}
					Box(".fullScreenUI") {
						VisualEffectView(material: .fullScreenUI)
							.size(width: 200, height: 50)
					}
					Box(".toolTip") {
						VisualEffectView(material: .toolTip)
							.size(width: 200, height: 50)
					}
				}
				HStack {
					Box(".contentBackground") {
						VisualEffectView(material: .contentBackground)
							.size(width: 200, height: 50)
					}
					Box(".underWindowBackground") {
						VisualEffectView(material: .underWindowBackground)
							.size(width: 200, height: 50)
					}
					Box(".underPageBackground") {
						VisualEffectView(material: .underPageBackground)
							.size(width: 200, height: 50)
					}
				}
			}
		}
		else {
			return Nothing()
		}
	}
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct VisualEffectBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				VisualEffectBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
