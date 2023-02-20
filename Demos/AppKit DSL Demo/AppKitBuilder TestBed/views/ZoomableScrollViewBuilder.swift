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
import DSFMenuBuilder

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

	let percentFormatter = NumberFormatter {
		$0.numberStyle = .percent
		$0.maximumFractionDigits = 0
	}
	private lazy var scaleFraction: ValueBinder<Double> = {
		ValueBinder(1.0) { [weak self] newValue in
			self?.title.wrappedValue = self?.percentFormatter.string(for: newValue) ?? ""
		}
	}()

	let scaleToFitFraction = ValueBinder(1.0)
	let title = ValueBinder("")

	lazy var body: Element = {
		VStack {
			HStack {
				PopupButton(pullsDown: true, bezelStyle: .roundRect) {
					MenuItem("25%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 0.25 }
					MenuItem("50%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 0.50 }
					MenuItem("75%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 0.75 }
					MenuItem("100%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 1.00 }
					MenuItem("125%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 1.25 }
					MenuItem("150%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 1.50 }
					MenuItem("200%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 2.00 }
					MenuItem("300%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 3.00 }
					MenuItem("400%")
						.onAction { [weak self] in self?.scaleFraction.wrappedValue = 4.00 }
					Separator()
					MenuItem("Fit")
						.onAction { [weak self] in
							guard let `self` = self else { return }
							self.scaleFraction.wrappedValue = self.scaleToFitFraction.wrappedValue
						}
				}
				.font(.label)
				.width(65)
				.bindTitle(self.title)

				VDivider()
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
