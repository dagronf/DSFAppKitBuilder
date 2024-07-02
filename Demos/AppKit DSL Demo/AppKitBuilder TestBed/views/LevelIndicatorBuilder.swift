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

public class LevelIndicatorBuilder: ViewTestBed {
	var title: String { String.localized("Level indicators") }
	var type: String { "LevelIndicator" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("NSLevelIndicator wrapper") }
	func build() -> ElementController {
		LevelIndicatorBuilderController()
	}
}

class LevelIndicatorBuilderController: ElementController {

	let value = ValueBinder(20.0)

	let discrete = ValueBinder(4.0)
	let rating = ValueBinder(2.0)

	let formatter: NumberFormatter = {
		let f = NumberFormatter()
		f.maximumFractionDigits = 0
		return f
	}()

	lazy var body: Element = {
		Group(layoutType: .center) {
			Form {
				Form.Row(
					"Continuous:",
					VStack {
						Slider(value, range: 0 ... 100)
							.verticalCompressionResistancePriority(.init(999))

						LevelIndicator(
							style: .continuousCapacity,
							value: value,
							range: 0 ... 100
						)
							.isEditable(true)
							.warning(70, color: .systemYellow)
							.critical(95, color: .systemRed)
							.height(18)
					}
				)

				Form.Row.Divider()

				Form.Row(
					"Discrete:",
					VStack {
						Slider(discrete, range: 0 ... 10)
							.numberOfTickMarks(11, allowsTickMarkValuesOnly: true)
							.verticalCompressionResistancePriority(.init(999))

						LevelIndicator(
							style: .discreteCapacity,
							value: discrete,
							range: 0 ... 10
						)
							.isEditable(true)
							.warning(7, color: .systemYellow)
							.critical(9, color: .systemRed)
							.height(18)
					}
				)

				Form.Row.Divider()

				Form.Row(
					"Rating:",
					HStack {
						LevelIndicator(
							style: .rating,
							value: rating,
							range: 0.001 ... 5
						)
						.isEditable(true)
						.width(80)

						Label(rating.stringValue(using: formatter))
					}
				)
			}
			.width(300)
			//.showDebugFrames()
		}
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct LevelIndicatorBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			LevelIndicatorBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
