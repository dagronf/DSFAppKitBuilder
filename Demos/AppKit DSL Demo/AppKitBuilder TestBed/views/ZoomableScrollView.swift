//
//  BlankTemplateBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 17/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders

public class ZoomableScrollviewBuilder: ViewTestBed {
	var title: String { String.localized("Zoomable ScrollView") }
	var type: String { "ScrollView" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("A scroll view that can scale its content") }
	func build() -> ElementController {
		ZoomableScrollviewBuilderController()
	}
}

class ZoomableScrollviewBuilderController: ElementController {

	let scaleFraction = ValueBinder(1.0)
	let scaleToFitFraction = ValueBinder(1.0)

	lazy var body: Element = {
		VStack {
			HStack {
				Slider(scaleFraction, range: 0.01 ... 10)
				Button(image: NSImage(named: "zoom-out")!, bezelStyle: .texturedSquare) { [weak self] _ in
					self?.scaleFraction.wrappedValue -= 0.1
				}
				Button(image: NSImage(named: "zoom-in")!, bezelStyle: .texturedSquare) { [weak self] _ in
					self?.scaleFraction.wrappedValue += 0.1
				}
				VDivider()
				Button(image: NSImage(named: "zoom-11")!, bezelStyle: .texturedSquare) { [weak self] _ in
					self?.scaleFraction.wrappedValue = 1
				}
				Button(image: NSImage(named: "zoom-fit")!, bezelStyle: .texturedSquare) { [weak self] _ in
					guard let `self` = self else { return }
					self.scaleFraction.wrappedValue = self.scaleToFitFraction.wrappedValue
				}
			}
			ZoomableScrollView(scaleBinder: scaleFraction, range: 0.1 ... 10, fitHorizontally: false) {
				ImageView(NSImage(named: "apple_logo_orig")!)
			}
			.bindZoomToFitScale(self.scaleToFitFraction)
			.horizontalHuggingPriority(.defaultLow)
			.verticalHuggingPriority(.defaultLow)
		}
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ZoomableScrollviewBuilderBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			ZoomableScrollviewBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
