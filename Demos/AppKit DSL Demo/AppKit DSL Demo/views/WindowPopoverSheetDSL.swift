//
//  WindowPopoverSheetDSL.swift
//  WindowPopoverSheet
//
//  Created by Darren Ford on 30/8/21.
//

import AppKit
import DSFAppKitBuilder

class WindowPopoverSheetDSL: NSObject, DSFAppKitBuilderViewHandler {

	let sliderValue = ValueBinder<Double>(25) { newValue in
		Swift.print("Slider value is now \(newValue)")
	}
	let sliderFormatter: NumberFormatter = {
		let n = NumberFormatter()
		n.maximumFractionDigits = 1
		n.minimumFractionDigits = 1
		return n
	}()

	override init() {
		super.init()
	}

	func showPopover() {
		guard let element = self.popoverLocator.element else {
			return
		}
		self.popover.show(relativeTo: element.bounds,
								of: element,
								preferredEdge: .maxY)
	}

	lazy var body: Element =
		Box("Popups and windows") {
			VStack(alignment: .leading) {
				HStack {
					Button(title: "Show Popup") { [weak self] _ in
						// Show the popover when the
						self?.showPopover()
					}
						.bindElement(self.popoverLocator)
					Label()
						.font(NSFont.userFixedPitchFont(ofSize: 13))
						.bindValue(self.sliderValue, formatter: self.sliderFormatter)
				}
				HStack {
					Button(title: "Show Window") { [weak self] _ in
						// Display a window when clicking this button
						self?.currentWindow = self?.createWindow()
					}
				}
				EmptyView()
			}
			.edgeInsets(8)
			.contentHugging(h: 10)
			.horizontalPriorities(hugging: 10, compressionResistance: 10)
			.verticalPriorities(hugging: 10, compressionResistance: 10)
		}
		.verticalPriorities(hugging: 100)
		.horizontalPriorities(hugging: 100)

	////////////////////
	// Popover
	////////////////////
	let popoverLocator = ElementBinder()
	lazy var popover: Popover = Popover {
		Group(edgeInset: 20,
				visualEffect: VisualEffect(material: .titlebar)) {
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
	.onOpen { _ in
		Swift.print("Popover opened...")
	}
	.onClose { _ in
		Swift.print("Popover closing...")
	}

	///////////////////
	// Sheet definition
	///////////////////
	let sheetBinder = SheetBinder()
	func createSheet() -> Sheet {
		return Sheet(
			title: "Sheet",
			contentRect: NSRect(x: 0, y: 0, width: 500, height: 200),
			styleMask: [.resizable],
			frameAutosaveName: "sheetie") {
				Group(edgeInset: 20) {
					VStack {
						Label("First!")
						EmptyView()
						Button(title: "Dismiss") { [weak self] _ in
							guard let `self` = self else { return }
							self.sheetBinder.dismiss(result: .OK)
						}
					}
				}
			}
			.onOpen { _ in
				Swift.print("Sheet did open...")
			}
			.onClose { _ in
				Swift.print("Sheet will close...")
			}
			.bindSheet(sheetBinder)
	}

	////////////////////
	// Window definition
	////////////////////
	let demoWindowElement = WindowBinder()
	let demoWindowFocusElement = ElementBinder()
	var currentWindow: Window?

	func createWindow() -> Window {
		return Window(
			title: "Wheeee!",
			contentRect: NSRect(x: 100, y: 100, width: 200, height: 200),
			styleMask: [.titled, .closable, .miniaturizable, .resizable], /*.fullSizeContentView])*/
			frameAutosaveName: "demoMainWindow-frame")
		{
			VisualEffectView(
				material: .menu,
				blendingMode: .behindWindow, isEmphasized: true)
			{
				Group(edgeInset: 20) {
					VStack {
						ImageView(NSImage(named: "slider-rabbit")!)
							.scaling(.scaleProportionallyUpOrDown)
							.minWidth(32).minHeight(32)
							.horizontalPriorities(hugging: 10, compressionResistance: 10)
							.verticalPriorities(hugging: 10, compressionResistance: 10)
						Label("Rabbit!").font(NSFont.systemFont(ofSize: 32, weight: .heavy))
						HStack {
							Button(title: "00") { [weak self] _ in self?.sliderValue.wrappedValue = 0 }
							Button(title: "20") { [weak self] _ in self?.sliderValue.wrappedValue = 20 }
							Button(title: "40") { [weak self] _ in self?.sliderValue.wrappedValue = 40 }
							Button(title: "60") { [weak self] _ in self?.sliderValue.wrappedValue = 60 }
								.bindElement(self.demoWindowFocusElement)
							Button(title: "80") { [weak self] _ in self?.sliderValue.wrappedValue = 80 }
							Button(title: "100") { [weak self] _ in self?.sliderValue.wrappedValue = 100 }
							Button(title: "Show sheet") { [weak self] _ in
								guard let `self` = self else { return }
								self.demoWindowElement.window?.presentModal(self.createSheet()) { result in
									Swift.print("Sheet result is \(result)")
								}
							}
						}
					}
				}
			}
		}
		.bindWindow(demoWindowElement)
		.onOpen { [weak self] window in
			Swift.print("Window opened, focussing on button '60'...")
			self?.demoWindowFocusElement.makeFirstResponder()
		}
		.onClose { [weak self] window in
			Swift.print("Window closing...")
			self?.currentWindow = nil
		}
	}
}



