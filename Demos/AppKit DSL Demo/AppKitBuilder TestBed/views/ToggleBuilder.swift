//
//  ToggleBuilder.swift
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

public class ToggleBuilder: ViewTestBed {
	var title: String { String.localized("Toggle") }
	var type: String { "Toggle" }
	var description: String { String.localized("An Element that displays a toggle button") }
	func build() -> ElementController {
		ToggleBuilderController()
	}
}

class ToggleBuilderController: ElementController {
	deinit {
		Swift.print("ToggleBuilderController: deinit")
	}

	let __visible = ValueBinder(0)

	private func largeSize() -> Element {
		if #available(macOS 11, *) {
			return VStack {
				Toggle(state: .on).controlSize(.large)
				Label(".large")
			}
		}
		return Nothing()
	}

	lazy var body: Element = {
		VStack(alignment: .leading) {
			Label("Default sizing")
			HStack {
				Toggle(state: .off)
				Toggle(state: .off)
					.isEnabled(false)
				Toggle(state: .on)
				Toggle(state: .on)
					.isEnabled(false)
			}
			HDivider()
			Label("Control sizing")
			HStack {
				VStack {
					Toggle(state: .on).controlSize(.mini)
					Label(".mini")
				}
				VStack {
					Toggle(state: .on).controlSize(.small)
					Label(".small")
				}
				VStack {
					Toggle(state: .on).controlSize(.regular)
					Label(".regular")
				}
				self.largeSize()
			}
			HDivider()
			Label("100x50, not labelled")
			HStack {
				Toggle(state: .off)
					.size(width: 100, height: 50)
				Toggle(state: .off)
					.isEnabled(false)
					.size(width: 100, height: 50)
				Toggle(state: .on)
					.size(width: 100, height: 50)
				Toggle(state: .on)
					.isEnabled(false)
					.size(width: 100, height: 50)
			}
			HDivider()
			Label("100x50, labelled")
			HStack {
				Toggle(state: .off, showLabels: true)
					.size(width: 100, height: 50)
				Toggle(state: .off, showLabels: true)
					.isEnabled(false)
					.size(width: 100, height: 50)
				Toggle(state: .on, showLabels: true)
					.isEnabled(true)
					.size(width: 100, height: 50)
				Toggle(state: .on, showLabels: true)
					.isEnabled(false)
					.size(width: 100, height: 50)
			}
			HDivider()
			Label("30x30, not labelled")
			HStack {
				Toggle(state: .off, color: NSColor.systemRed)
					.size(width: 30, height: 30)
				Toggle(state: .on, color: NSColor.systemRed)
					.size(width: 30, height: 30)
				Toggle(state: .on, color: NSColor.systemGreen)
					.size(width: 30, height: 30)
				Toggle(state: .on, color: NSColor.systemBlue)
					.size(width: 30, height: 30)
			}
			HDivider()
			Label("150x100")
			HStack {
				Toggle(state: .on, color: NSColor.systemRed)
					.size(width: 150, height: 100)
				Toggle(state: .on, color: NSColor.systemGreen)
					.size(width: 150, height: 100)
				Toggle(state: .on, color: NSColor.systemBlue)
					.size(width: 150, height: 100)
			}
			HDivider()
			Label("400x300")
			HStack {
				Toggle(state: .off, color: NSColor.systemYellow, showLabels: true)
					.size(width: 300, height: 200)
				Toggle(state: .on, color: NSColor.systemYellow, showLabels: true)
					.size(width: 300, height: 200)
			}
		}
		.hugging(h: 10)

	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ToggleBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				ToggleBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
