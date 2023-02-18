//
//  PopoverSheetBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 17/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders

public class PopoverSheetBuilder: ViewTestBed {
	var title: String { String.localized("Sheets and popovers") }
	var type: String { "" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("Sheet and popovers") }
	func build() -> ElementController {
		PopoverSheetBuilderController()
	}
}

class PopoverSheetBuilderController: ElementController {
	let show = ValueBinder(false)
	let popoverShow = ValueBinder(false) { newState in
		Swift.print("Popover state is '\(newState)'")
	}

	deinit {
		Swift.print("\(self.self): deinit")
	}

	let sliderValue = ValueBinder(65.0)
	let sliderFormatter = NumberFormatter {
		$0.maximumFractionDigits = 1
		$0.minimumFractionDigits = 1
	}

	// The content of the popover
	lazy var popoverContentBuilder: (() -> Element) = { [weak self] in
		guard let `self` = self else { return Nothing() }
		return Group(edgeInset: 20) {
			VStack {
				Label("Update the slider value")
					.font(NSFont.boldSystemFont(ofSize: 14))
				HStack {
					ImageView(NSImage(named: "slider-tortoise")!)
						.scaling(.scaleProportionallyDown)
						.size(width: 24, height: 24)
					Slider(range: 0 ... 100, value: 0)
						.minWidth(250)
						.bindValue(self.sliderValue)
					ImageView(NSImage(named: "slider-rabbit")!)
						.scaling(.scaleProportionallyDown)
						.size(width: 24, height: 24)
				}
			}
		}
	}

	// The content of the sheet
	lazy var sheetContentBuilder: (() -> Element) = { [weak self] in
		VStack(alignment: .leading) {
			HStack {
				ImageView(NSImage(named: NSImage.cautionName))
					.size(width: 48, height: 48)
				Label("Do something?")
			}
			HStack {
				EmptyView()
				HStack(alignment: .trailing, distribution: .fillEqually) {
					Button(title: "OK", bezelStyle: .rounded) { [weak self] _ in
						self?.show.wrappedValue = false
					}
					Button(title: "Cancel", bezelStyle: .rounded) { [weak self] _ in
						self?.show.wrappedValue = false
					}
					.bezelColor(NSColor.systemRed)
				}
			}
		}
		.width(400)
		.padding(20)
	}

	lazy var body: Element = {
		Group(layoutType: .center) {
			VStack {
				Button(title: "Present a modal sheet") { [weak self] _ in
					self?.show.wrappedValue = true
				}
				.sheet(isVisible: show, sheetContentBuilder)

				HStack {
					Button(title: "Display a popover") { [weak self] _ in
						self?.popoverShow.wrappedValue = true
					}
					.popover(
						isVisible: self.popoverShow,
						preferredEdge: .maxY,
						popoverContentBuilder
					)
					Label()
						.font(NSFont.userFixedPitchFont(ofSize: 13))
						.bindValue(self.sliderValue, formatter: self.sliderFormatter)
						.width(40)
				}
			}
		}
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct PopoverSheetTemplateBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			PopoverSheetBuilderController().body
				.SwiftUIPreview()
		}
	}
}

@available(macOS 10.15, *)
struct SheetContentBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			PopoverSheetBuilderController().sheetContentBuilder()
				.SwiftUIPreview()
		}
	}
}

@available(macOS 10.15, *)
struct PopoverContentBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			PopoverSheetBuilderController().popoverContentBuilder()
				.SwiftUIPreview()
		}
	}
}
#endif
