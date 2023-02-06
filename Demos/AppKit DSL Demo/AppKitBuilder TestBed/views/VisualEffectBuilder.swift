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
						VisualEffectView(material: .titlebar) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".selection") {
						VisualEffectView(material: .selection) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".menu") {
						VisualEffectView(material: .menu) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
				}

				HStack {
					Box(".popover") {
						VisualEffectView(material: .popover) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".sidebar") {
						VisualEffectView(material: .sidebar) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
				}

				HDivider()

				self.buildModernEffects()
			}
		}
	}()

	func buildModernEffects() -> Element {
		if #available(macOS 10.14, *) {
			return VStack(alignment: .leading) {
				Label("Available 10.14+").font(.title3)
				HStack {
					Box(".headerView") {
						VisualEffectView(material: .headerView) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".sheet") {
						VisualEffectView(material: .sheet) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".windowBackground") {
						VisualEffectView(material: .windowBackground) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
				}

				HStack {
					Box(".hudWindow") {
						VisualEffectView(material: .hudWindow) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".fullScreenUI") {
						VisualEffectView(material: .fullScreenUI) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".toolTip") {
						VisualEffectView(material: .toolTip) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
				}
				HStack {
					Box(".contentBackground") {
						VisualEffectView(material: .contentBackground) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".underWindowBackground") {
						VisualEffectView(material: .underWindowBackground) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
					}
					Box(".underPageBackground") {
						VisualEffectView(material: .underPageBackground) {
							EmptyView()
								.size(width: 200, height: 50)
						}
						.horizontalHuggingPriority(10)
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
