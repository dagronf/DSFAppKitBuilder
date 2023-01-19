//
//  ViewController.swift
//  AKBView Test
//
//  Created by Darren Ford on 18/1/2023.
//

import Cocoa
import DSFAppKitBuilder
import DSFValueBinders
import DSFToolbar

class ViewController: NSViewController {

	@IBOutlet weak var coreView: DSFAppKitBuilderView!

	var titleValue: ValueBinder<String>? = ValueBinder("555 Amity Crt, Somewhereville") { newValue in
		Swift.print("title is now '\(newValue)'")
	}

	let titleBinder = ElementBinder()

	var colorBinder1 = ValueBinder(NSColor.textColor)
	var colorBinder2 = ValueBinder(NSColor.secondaryLabelColor)
	var colorBinder3 = ValueBinder(NSColor.tertiaryLabelColor)

	let identity = IdentityViewController()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Create a subview
		let subView = DSFAppKitBuilderView {
			HStack {
				ColorWell(style: .default)
					.bindColor(colorBinder1)
					.size(width: 70, height: 30)
				ColorWell(style: .expanded)
					.bindColor(colorBinder2)
					.size(width: 70, height: 30)
				ColorWell(style: .minimal, showsAlpha: true)
					.bindColor(colorBinder3)
					.size(width: 70, height: 30)
			}
		}

		self.coreView.element = {
			VStack {
				Label("Hello monospaced digit 23.56")
					.horizontalPriorities(compressionResistance: 100)
					.font(.monospaced.weight(.heavy))
					.lineBreakMode(NSLineBreakMode.byTruncatingTail)

				TextField("Wooble")
					.bindText(titleValue!)
					.isScrollable(true)
					.font(.largeTitle)
					.bindElement(titleBinder)

				HDivider()

				Label("Hello title1").font(.title1)
					.bindTextColor(colorBinder1)
				Label("Hello title2").font(.title2.italic())
					.bindTextColor(colorBinder2)
				Label("Hello title3").font(.title3.bold())
					.bindTextColor(colorBinder3)

				// Embed a DSFAppKitBuilderView in this view
				View(subView)

				HDivider()

				// Embed a DSFAppKitBuilderViewController in this view
				View(self.identity)
					.padding(16)
					.border(width: 0.5, color: NSColor.secondaryLabelColor)

				Button(title: "Destroy") { [weak self] _ in
					self?.remove()
				}
			}
		}()
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		self.customToolbar.attachedWindow = self.view.window
	}

	func remove() {
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			self.coreView.element = nil
			self.titleValue = nil
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	private lazy var selection = ValueBinder<NSSet>(NSSet(array: [1])) { [weak self] newValue in
		Swift.print("Selection is now \(newValue)")
		guard let `self` = self else { return }

		if newValue.contains(0) {
			(self.titleBinder.view as! NSTextField).alignment = .left
		}
		else if newValue.contains(1) {
			(self.titleBinder.view as! NSTextField).alignment = .center
		}
		else if newValue.contains(2) {
			(self.titleBinder.view as! NSTextField).alignment = .right
		}
	}

	let format = ValueBinder<NSSet>(NSSet(array: [])) { newValue in
		Swift.print("Format is now \(newValue)")
	}

	lazy var customToolbar = {
		DSFToolbar("Main Toolbar", allowsUserCustomization: true) {
			DSFToolbar.Item(.init("press-share"))
				.label("Share")
				.image(NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)!)
				.action { item in
					Swift.print("Pressed share button")
				}
			DSFToolbar.Item(.init("press-trash"))
				.label("Trash")
				.image(NSImage(systemSymbolName: "trash", accessibilityDescription: nil)!)
				.action { item in
					Swift.print("Pressed trash button")
				}
			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				.init("alignment"),
				type: .Grouped,
				switching: .selectOne
				) {
					DSFToolbar.Segmented.Segment(title: "")
						.image(NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: nil)!, scaling: .scaleNone)
					DSFToolbar.Segmented.Segment(title: "")
						.image(NSImage(systemSymbolName: "text.aligncenter", accessibilityDescription: nil)!, scaling: .scaleNone)
					DSFToolbar.Segmented.Segment(title: "")
						.image(NSImage(systemSymbolName: "text.alignright", accessibilityDescription: nil)!, scaling: .scaleNone)
				}
				.label("Alignment")
				.bindSelection(selection)

			DSFToolbar.Segmented(
				.init("format"),
				type: .Grouped,
				switching: .selectAny
				) {
					DSFToolbar.Segmented.Segment(title: "")
						.image(NSImage(systemSymbolName: "bold", accessibilityDescription: nil)!, scaling: .scaleNone)
					DSFToolbar.Segmented.Segment(title: "")
						.image(NSImage(systemSymbolName: "italic", accessibilityDescription: nil)!, scaling: .scaleNone)
					DSFToolbar.Segmented.Segment(title: "")
						.image(NSImage(systemSymbolName: "underline", accessibilityDescription: nil)!, scaling: .scaleNone)
				}
				.label("Format")
				.bindSelection(format)

//			DSFToolbar.Group(
//				.init("segment"),
//				selectionMode: .selectOne
//			) {
//				DSFToolbar.Item(.init("alignment-left"))
//					//.label("left")
//					.image(NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: nil)!)
//					.action { item in
//						Swift.print("Pressed left button")
//					}
//				DSFToolbar.Item(.init("alignment-center"))
//					//.label("center")
//					.image(NSImage(systemSymbolName: "text.aligncenter", accessibilityDescription: nil)!)
//					.action { item in
//						Swift.print("Pressed center button")
//					}
//				DSFToolbar.Item(.init("alignment-right"))
//					//.label("right")
//					.image(NSImage(systemSymbolName: "text.alignright", accessibilityDescription: nil)!)
//					.action { item in
//						Swift.print("Pressed right button")
//					}
//			}
//			.label("Alignment")
//			.isBordered(true)

		}
	}()
}



