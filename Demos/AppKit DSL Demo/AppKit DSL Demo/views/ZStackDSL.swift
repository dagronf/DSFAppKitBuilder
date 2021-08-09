//
//  ZStackDSL.swift
//  ZStackDSL
//
//  Created by Darren Ford on 9/8/21.
//

import AppKit
import DSFAppKitBuilder

class ZStackDSL: NSObject, DSFAppKitBuilderViewHandler {
	lazy var body: Element =
	ZStack {
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
				.additionalAppKitControlSettings { (b: NSButton) in
					b.font = NSFont.boldSystemFont(ofSize: 24)
				}
		}
	}
}
