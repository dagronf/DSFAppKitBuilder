//
//  ViewController.swift
//  AKBView Test
//
//  Created by Darren Ford on 18/1/2023.
//

import Cocoa
import DSFAppKitBuilder
import DSFValueBinders

class ViewController: NSViewController {

	@IBOutlet weak var coreView: DSFAppKitBuilderView!

	var titleValue: ValueBinder<String>? = ValueBinder("555 Amity Crt, Somewhereville") { newValue in
		Swift.print("title is now '\(newValue)'")
	}

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

				HDivider()

				Label("Hello title1").font(.title1)
					.bindTextColor(colorBinder1)
				Label("Hello title2").font(.title2.italic())
					.bindTextColor(colorBinder2)
				Label("Hello title3").font(.title3.bold())
					.bindTextColor(colorBinder3)

				// Embed a DSFAppKitBuilderView in this view
				View(subView)

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
}



