//
//  ZStackDSL.swift
//  ZStackDSL
//
//  Created by Darren Ford on 9/8/21.
//

import AppKit
import DSFAppKitBuilder
import DSFValueBinders

class ZStackDSL: NSObject, DSFAppKitBuilderViewHandler {

	//@objc dynamic var fileURL: URL = Bundle.main.bundleURL

	let fileURL = ValueBinder<URL>(Bundle.main.bundleURL) { newValue in
		Swift.print("file url is now '\(newValue)'")
	}

	override init() {
		super.init()
	}

	lazy var body: Element =
	VStack {
		ZStack(edgeInset: 8) {
			ZLayer {
				ImageView(NSImage(named: "apple_logo_orig")!)
					.horizontalPriorities(compressionResistance: 10)
					.verticalPriorities(compressionResistance: 10)
					.scaling(.scaleProportionallyUpOrDown)
			}
			ZLayer {
				VStack(alignment: .centerX) {
					EmptyView()
					Label("Apple Computer")
						.font(NSFont.boldSystemFont(ofSize: 32))
					EmptyView().height(12)
				}
			}
			ZLayer(layoutType: .center) {
				Button(title: "Do it!", bezelStyle: .regularSquare) { _ in
					Swift.print("Clicked 'Do it!'")
				}
					.font(NSFont.boldSystemFont(ofSize: 24))
			}
		}
		.border(width: 0.5, color: .tertiaryLabelColor)
		.cornerRadius(8)

		// Path control

		HStack {
			PathControlWithSelector(fileURL: self.fileURL)
			Button(title: "Reset") { _ in
				self.fileURL.wrappedValue = Bundle.main.bundleURL
			}
		}
	}
}



class PathControlWithSelector: Element {

	let fileURL: ValueBinder<URL>

	public init(fileURL: ValueBinder<URL>) {
		self.fileURL = fileURL
		super.init()
	}

	override func view() -> NSView {
		return self.body.view()
	}

	lazy var body: Element =
		HStack {
			PathControl(bindingURL: fileURL)
				.horizontalPriorities(hugging: 10, compressionResistance: 10)
			Button(title: "…", bezelStyle: .roundRect) { _ in
				self.selectFile()
			}
		}
		.edgeInsets(top: 2, left: 3, bottom: 2, right: 3)
		.border(width: 0.5, color: .tertiaryLabelColor)
		.cornerRadius(4)
		.backgroundColor(.quaternaryLabelColor)

	private func selectFile() {
		let openPanel = NSOpenPanel()
		openPanel.directoryURL = self.fileURL.wrappedValue
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = true
		openPanel.begin { [weak self] (result) -> Void in
			guard let `self` = self else { return }
			if result == NSApplication.ModalResponse.OK,
				let url = openPanel.url {
				self.fileURL.wrappedValue = url
			}
		}
	}
}
