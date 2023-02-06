//
//  ColorWellBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 4/2/2023.
//

import Foundation
import AppKit

import DSFAppearanceManager
import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

public class ColorWellBuilder: ViewTestBed {
	var title: String { String.localized("Color Well") }
	var type: String { "ColorWell" }
	var description: String { String.localized("An Element that allows the user to display exactly one of the child elements at any time") }
	func build() -> ElementController {
		ColorWellBuilderController()
	}
}

class ColorWellBuilderController: ElementController {
	deinit {
		Swift.print("ColorWellBuilderController: deinit")
	}

	let color1 = ValueBinder(NSColor.red)
	let color2 = ValueBinder(NSColor.green)
	let color3 = ValueBinder(NSColor.blue)

	lazy var body: Element = {
		VStack {
			Group(layoutType: .center) {
				Grid(columnSpacing: 16) {
					GridRow(rowAlignment: .firstBaseline) {
						Label("Style").font(.title2)
						Label("Bordered").font(.title2)
						Label("No border").font(.title2)
						Label("Disabled").font(.title2)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".default").font(.monospaced.size(14))
						ColorWell(style: .default, showsAlpha: true, isBordered: true)
							.size(width: 60, height: 26)
							.bindColor(color1)
						ColorWell(style: .default, showsAlpha: true, isBordered: false)
							.size(width: 60, height: 26)
							.bindColor(color1)
						ColorWell(style: .default, showsAlpha: true, isBordered: true)
							.size(width: 60, height: 26)
							.bindColor(color1)
							.isEnabled(false)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".minimal").font(.monospaced.size(14))
						ColorWell(style: .minimal, showsAlpha: true, isBordered: true)
							.size(width: 60, height: 26)
							.bindColor(color2)
						ColorWell(style: .minimal, showsAlpha: true, isBordered: false)
							.size(width: 60, height: 26)
							.bindColor(color2)
						ColorWell(style: .minimal, showsAlpha: true, isBordered: false)
							.size(width: 60, height: 26)
							.bindColor(color2)
							.isEnabled(false)

					}
					GridRow(rowAlignment: .firstBaseline) {
						Label(".expanded").font(.monospaced.size(14))
						ColorWell(style: .expanded, showsAlpha: true, isBordered: true)
							.size(width: 60, height: 26)
							.bindColor(color3)
						ColorWell(style: .expanded, showsAlpha: true, isBordered: false)
							.size(width: 60, height: 26)
							.bindColor(color3)
						ColorWell(style: .expanded, showsAlpha: true, isBordered: false)
							.size(width: 60, height: 26)
							.bindColor(color3)
							.isEnabled(false)

					}
				}
				.columnFormatting(xPlacement: .center, atColumn: 1)
				.columnFormatting(xPlacement: .center, atColumn: 2)
				.columnFormatting(xPlacement: .center, atColumn: 3)
			}
		}
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ColorWellBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				ColorWellBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
