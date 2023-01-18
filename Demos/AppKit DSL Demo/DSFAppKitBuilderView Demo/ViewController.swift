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

	var titleValue: ValueBinder<String>? = ValueBinder("Womble") { newValue in
		Swift.print("title is now '\(newValue)'")
	}

	var colorBinder = ValueBinder(NSColor.textColor)


	override func viewDidLoad() {
		super.viewDidLoad()

		// Create a subview
		let subView = DSFAppKitBuilderView {
			ColorWell()
				.bindColor(colorBinder)
				.size(width: 50, height: 26)
		}

		self.coreView.element = {
			VStack {
				Label("Hello title1").font(.title1)
					.bindTextColor(colorBinder)
				Label("Hello title2").font(.title2.italic())
					.bindTextColor(colorBinder)
				Label("Hello monospaced digit 23.56")
					.horizontalPriorities(compressionResistance: 100)
					.font(.monospaced.weight(.heavy))
					.lineBreakMode(NSLineBreakMode.byTruncatingTail)
				TextField("Wooble")
					.bindText(titleValue!)
					.font(.largeTitle)

				HDivider()

				View(subView)

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

