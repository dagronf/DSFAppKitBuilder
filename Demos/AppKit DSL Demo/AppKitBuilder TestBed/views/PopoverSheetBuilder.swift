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
import DSFToolbar

public class PopoverSheetBuilder: ViewTestBed {
	var title: String { String.localized("Windows/Sheets/Popovers") }
	var type: String { "" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("Windows, sheets and popovers") }
	func build() -> ElementController {
		PopoverSheetBuilderController()
	}
}

class PopoverSheetBuilderController: ElementController {
	let show = ValueBinder(false)
	let popoverShow = ValueBinder(false) { newState in
		Swift.print("Popover state is '\(newState)'")
	}

	lazy var customToolbar: DSFToolbar = {
		DSFToolbar(

			toolbarIdentifier: NSToolbar.Identifier("Core"),
			allowsUserCustomization: true) {

				DSFToolbar.Item(NSToolbarItem.Identifier("item-new"))
					.label("New")
					.isSelectable(true)
					.image(NSImage(named: "slider-rabbit")!)
					.shouldEnable { [weak self] in
						false
					}
					.action { [weak self] _ in
						Swift.print("Custom button pressed")
					}
			}
	}()


	private let presentedWindowVisible = ValueBinder(false)
	private let presentedWindowTitle = ValueBinder("Window")
	let window: MyWindow

	init() {
		self.window = MyWindow(isVisible: self.presentedWindowVisible)
		self.window.bindTitle(self.presentedWindowTitle)
		self.window.onOpen { [weak self] window in
			Swift.print("MyWindow: onOpen")
			self?.customToolbar.attachedWindow = window.window
			window.toolbarStyle(.preference)
		}
		self.window.onClose { _ in
			Swift.print("MyWindow: onClose")
		}
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
				.sheet(
					isVisible: show,
					frameAutosaveName: "Present:Sheet",
					sheetContentBuilder
				)

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

				Box("Presenting a window") {
					HStack {
						Label("Title:")
						TextField(presentedWindowTitle)
							.width(100)

						Button(title: "Show") { [weak self] _ in
							self?.presentedWindowVisible.wrappedValue = true
						}
						.bindIsEnabled(presentedWindowVisible.toggled())
						Button(title: "Close") { [weak self] _ in
							self?.presentedWindowVisible.wrappedValue = false
						}
						.bindIsEnabled(presentedWindowVisible)
					}
				}
				.horizontalHuggingPriority(.defaultLow)
			}
		}
	}()
}

class MyWindow: ManagedWindow {
	override var title: String { "Whee!" }
	override var styleMask: NSWindow.StyleMask { [.titled, .closable, .miniaturizable, .resizable] }
	override var isMovableByWindowBackground: Bool { true }
	override var frameAutosaveName: NSWindow.FrameAutosaveName? { "MyWindow:Position" }
	override func buildContent() -> Element {
		VisualEffectView(
			material: .menu,
			blendingMode: .behindWindow, isEmphasized: true)
		{
			Group(edgeInset: 20) {
				VStack {
					Label("How exciting!")
				}
			}
		}
	}

	deinit {
		Swift.print("MyWindow: deinit")
	}
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
