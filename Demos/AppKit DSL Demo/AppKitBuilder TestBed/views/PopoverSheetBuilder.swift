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
	var description: String { String.localized("Windows, sheets and popovers") }
	func build() -> ElementController {
		PopoverSheetBuilderController()
	}
}

class PopoverSheetBuilderController: ElementController {
	let sheetVisible = ValueBinder(false)
	let popoverShow = ValueBinder(false) { newState in
		Swift.print("Popover state is '\(newState)'")
	}

	private let presentedPanelVisible = ValueBinder(false)
	private let myPanel: MyPanel

	// Alert defintions
	private let alertResultString = ValueBinder("")
	private let presentedAlertVisible = ValueBinder(false)

	// Window definitions
	let secondWindow: MyWindow
	private let presentedWindowVisible = ValueBinder(false)
	private let presentedWindowMinimised = ValueBinder(false)
	private let presentedWindowTitle = ValueBinder("Window")

	// Sheet definition
	let mySheet: MySheet

	// Popover definition
	let myPopover: MyPopover

	init() {
		// The secondary window
		self.secondWindow = MyWindow(isVisible: self.presentedWindowVisible)

		// The panel to display
		self.myPanel = MyPanel()

		// The sheet
		self.mySheet = MySheet()

		// The popover
		self.myPopover = MyPopover(sliderValue: self.sliderValue)

		self.secondWindow.bindTitle(self.presentedWindowTitle)
		self.secondWindow.bindMinimise(self.presentedWindowMinimised)
		self.secondWindow.onOpen { window in // [weak self] window in
			Swift.print("MyWindow: onOpen")
		}
		self.secondWindow.onClose { _ in
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

	func buildAlert() -> (() -> NSAlert) {
		{
			let a = NSAlert()
			a.messageText = "Delete the document?"
			a.informativeText = "Are you sure you would like to delete the document?"
			a.addButton(withTitle: "Cancel")
			a.addButton(withTitle: "Delete")
			a.alertStyle = .warning
			a.icon = NSImage(named: "slider-tortoise")
			return a
		}
	}

	lazy var body: Element = {
		VStack(alignment: .leading) {
			Label("Alerts").font(.headline)

			HStack {
				Button(title: "Show an alert") { [weak self] _ in
					self?.presentedAlertVisible.wrappedValue = true
				}
				.alert(isVisible: self.presentedAlertVisible, alertBuilder: self.buildAlert()) { [weak self] response in
					//Swift.print("Alert response was: \(response)")
					self?.alertResultString.wrappedValue = "Response was: \(response.rawValue)"
				}
				Label(self.alertResultString)
					.font(NSFont.userFixedPitchFont(ofSize: 13))
			}

			HDivider()

			Label("Sheets").font(.headline)

			// Sheet
			Button(title: "Present a modal sheet") { [weak self] _ in
				self?.sheetVisible.wrappedValue = true
			}
			.sheet(mySheet, isVisible: self.sheetVisible)

			HDivider()

			Label("Popover").font(.headline)

			// Popover
			HStack {
				Button(title: "Display a popover") { [weak self] _ in
					self?.popoverShow.wrappedValue = true
				}
				.popover(self.myPopover, isVisible: self.popoverShow)
				Label()
					.font(NSFont.userFixedPitchFont(ofSize: 13))
					.bindValue(self.sliderValue, formatter: self.sliderFormatter)
					.width(40)
			}

			HDivider()

			Label("Popover").font(.headline)

			HStack {
				Button(title: "Show") { [weak self] _ in
					self?.presentedPanelVisible.wrappedValue = true
				}
				.panel(self.myPanel, isVisible: self.presentedPanelVisible)
				.bindIsEnabled(self.presentedPanelVisible.toggled())

				Button(title: "Close") { [weak self] _ in
					self?.presentedPanelVisible.wrappedValue = false
				}
				.bindIsEnabled(self.presentedPanelVisible)
			}

			HDivider()

			Label("Windows").font(.headline)

			Box("Primary functions") {

				VStack(alignment: .leading) {
					HStack {
						Label("Title:")
						TextField(presentedWindowTitle)
					}

					HStack {
						Button(title: "Show") { [weak self] _ in
							self?.presentedWindowVisible.wrappedValue = true
						}
						.bindIsEnabled(presentedWindowVisible.toggled())

						Button(title: "Toggle minimise") { [weak self] _ in
							self?.presentedWindowMinimised.wrappedValue.toggle()
						}
						.bindIsEnabled(presentedWindowVisible)

						Button(title: "Bring to front") { [weak self] _ in
							self?.presentedWindowVisible.wrappedValue = true
						}
						.bindIsEnabled(presentedWindowVisible)

						Button(title: "Close") { [weak self] _ in
							self?.presentedWindowVisible.wrappedValue = false
						}
						.bindIsEnabled(presentedWindowVisible)
					}
				}
				.horizontalHuggingPriority(.defaultLow)
			}

			DSFAppKitBuilder.EmptyView()
		}
		.hugging(h: 10)
	}()
}

// MARK: - The secondary window definition

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

	override var toolbarStyle: DSFAppKitBuilder.Window.ToolbarStyle { .preference }

	override func windowDidOpen(_ window: DSFAppKitBuilder.Window) {
		window.toolbarStyle(.preference)
		self.customToolbar.attachedWindow = window.window
	}

	lazy var customToolbar: DSFToolbar = {
		DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("Core"),
			allowsUserCustomization: true) {
				DSFToolbar.Item(NSToolbarItem.Identifier("item-new"))
					.label("New")
					.isSelectable(true)
					.image(NSImage(named: "slider-rabbit")!)
					.willEnable { [weak self] in
						false
					}
					.action { [weak self] _ in
						Swift.print("Custom button pressed")
					}
			}
	}()

	deinit {
		Swift.print("MyWindow: deinit")
	}
}

// MARK: The panel definition

class MyPanel: InspectorPanelDefinition {

	let showAlert = ValueBinder(false)
	func buildAlert() -> (() -> NSAlert) {
		{
			let a = NSAlert()
			a.messageText = "Yay you reloaded!"
			a.addButton(withTitle: "OK")
			a.alertStyle = .informational
			return a
		}
	}

	override var title: String { "Inspector" }
	override func buildContent() -> (() -> Element) {
		{ [weak self] in
			guard let `self` = self else { return Nothing() }
			return VStack {
				Grid {
					GridRow(mergeCells: [0...1]) {
						Label("VIDEO").font(.body.bold())
						Grid.EmptyCell()
					}
					GridRow {
						Label("Resolution:").font(.body.bold())
						Label("1920x800")
					}
					GridRow {
						Label("Format:").font(.body.bold())
						Label("h264")
					}
					GridRow {
						Label("HW Decoder:").font(.body.bold())
						Label("videotoolbox")
					}
					GridRow {
						Label("Bit rate:").font(.body.bold())
						Label("4.23 Mbps")
					}
					GridRow {
						Label("FPS:").font(.body.bold())
						Label("23.97")
					}
					GridRow(mergeCells: [0...1]) {
						HDivider()
						Grid.EmptyCell()
					}
					GridRow(mergeCells: [0...1]) {
						Label("AUDIO").font(.body.bold())
						Grid.EmptyCell()
					}
					GridRow {
						Label("Format:").font(.body.bold())
						Label("floatp")
					}
					GridRow {
						Label("Channels:").font(.body.bold())
						Label("stereo")
					}
				}
				.verticalHuggingPriority(.required)

				HDivider()

				Button(title: "Reload", bezelStyle: .inline) { [weak self] _ in
					self?.showAlert.wrappedValue = true
				}
				.verticalHuggingPriority(.required)
				.alert(isVisible: self.showAlert, alertBuilder: self.buildAlert()) { response in

				}
			}
			.hugging(v: 999)
			.padding(16)
		}
	}
}

class MySheet: SheetDefinition {
	override var frameAutosaveName: NSWindow.FrameAutosaveName? { "Present:Sheet" }
	override func buildContent() -> (() -> Element) {
		{ [weak self] in
			VStack(alignment: .leading) {
				HStack {
					ImageView(NSImage(named: NSImage.cautionName))
						.size(width: 48, height: 48)
					Label("Do something?")
				}
				HStack {
					DSFAppKitBuilder.EmptyView()
					HStack(alignment: .trailing, distribution: .fillEqually) {
						Button(title: "OK", bezelStyle: .rounded) { [weak self] _ in
							self?.dismiss()
						}
						Button(title: "Cancel", bezelStyle: .rounded) { [weak self] _ in
							self?.dismiss()
						}
						.bezelColor(NSColor.systemRed)
					}
				}
			}
			.hugging(v: 999)
			.width(400)
			.padding(20)
		}
	}
	deinit {
		Swift.print("MySheet: deinit")
	}
}

class MyPopover: PopoverDefinition {

	init(sliderValue: ValueBinder<Double>) {
		self.sliderValue = sliderValue
	}

	let sliderValue: ValueBinder<Double>

	override func buildContent() -> (() -> Element) {
		{ [weak self] in
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
					Button(title: "Close") { [weak self] _ in
						self?.dismiss()
					}
				}
			}
		}
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

private let __dummyPanel = MyPanel()
@available(macOS 10.15, *)
struct MyPanelPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		__dummyPanel.buildContent()()
			.SwiftUIPreview()
	}
}

private let __dummySheet = MySheet()
@available(macOS 10.15, *)
struct MySheetPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		__dummySheet.buildContent()()
			.SwiftUIPreview()
	}
}

private let __dummyValue = ValueBinder(65.0)
private let __dummyPopover = MyPopover(sliderValue: __dummyValue)
@available(macOS 10.15, *)
struct MyPopoverPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		__dummyPopover.buildContent()()
			.SwiftUIPreview()
	}
}

#endif
