//
//  ZStackDSL.swift
//  ZStackDSL
//
//  Created by Darren Ford on 9/8/21.
//

import AppKit
import DSFAppKitBuilder

class ZStackDSL: NSObject, DSFAppKitBuilderViewHandler {

	@objc dynamic var fileURL: URL = Bundle.main.bundleURL

	lazy var body: Element =
	VStack {
		ZStack(edgeOffset: 8) {
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
				Button(title: "Do it!", bezelStyle: .regularSquare)
					.font(NSFont.boldSystemFont(ofSize: 24))
			}
		}
		.border(width: 0.5, color: .tertiaryLabelColor)
		.cornerRadius(8)

		// Path control

		HStack {
			PathControl()
				.bindURL(self, keyPath: \ZStackDSL.fileURL)
				.horizontalPriorities(hugging: 10, compressionResistance: 10)
			Button(title: "…", bezelStyle: .roundRect) { _ in
				self.selectFile()
			}
		}
		.edgeInsets(top: 2, left: 3, bottom: 2, right: 3)
		.border(width: 0.5, color: .separatorColor)
		.cornerRadius(4)
		.backgroundColor(.quaternaryLabelColor)
	}

	private func selectFile() {
		let openPanel = NSOpenPanel()
		openPanel.directoryURL = fileURL
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = true
		openPanel.begin { [weak self] (result) -> Void in
			if result == NSApplication.ModalResponse.OK,
				let url = openPanel.url {
				self?.fileURL = url
			}
		}
	}

}
