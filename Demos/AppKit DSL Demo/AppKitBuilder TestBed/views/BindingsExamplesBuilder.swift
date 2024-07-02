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

public class BindingsExampleBuilder: ViewTestBed {
	var title: String { String.localized("Bindings Example") }
	var type: String { "Bindings" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("Some basic bindings tests") }
	func build() -> ElementController {
		BindingsExampleBuilderController()
	}
}

class BindingsExampleBuilderController: ElementController {
	let widthBinder = ValueBinder(50.0)
	let heightBinder = ValueBinder(50.0)

	let fillColor = ValueBinder<NSColor>(NSColor.textBackgroundColor)
	let strokeColor = ValueBinder<NSColor>(NSColor.textColor)
	let lineWidth = ValueBinder<Double>(2)

	lazy var body: Element = {
		DSFAppKitBuilder.VStack {
			Grid {
				GridRow {
					DSFAppKitBuilder.EmptyView()
					Slider(widthBinder, range: 10 ... 200)
						.width(200)
				}
				GridRow {
					Slider(heightBinder, range: 10 ... 200, isVertical: true)
						.height(200)
					Group(layoutType: .center) {
						DSFAppKitBuilder.EmptyView()
							.bindWidth(widthBinder)
							.bindHeight(heightBinder)
							.backgroundColor(.blue)
					}
				}
			}
			.contentHuggingPriority(h: 999, v: 999)

			HDivider()

			DSFAppKitBuilder.VStack {
				Shape(path: starPath)
					.bindFillColor(fillColor)
					.bindStrokeColor(strokeColor)
					.bindLineWidth(lineWidth)

				Form(rowSpacing: 8) {
					Form.Row(
						"fill color:",
						HStack {
							DSFAppKitBuilder.EmptyView()
							ColorWell(style: .default, showsAlpha: true, isBordered: true)
								.bindColor(fillColor)
								.width(50)
						}
					)
					Form.Row(
						"stroke color:",
						HStack {
							DSFAppKitBuilder.EmptyView()
							ColorWell(style: .default, showsAlpha: true, isBordered: true)
								.bindColor(strokeColor)
								.width(50)
						}
					)
					Form.Row("line width:",
						Slider(lineWidth, range: 0 ... 16)
							.width(100)
					)
				}
			}
		}
	}()
}

let starPath: CGPath = {
	let starPath = CGMutablePath()
	starPath.move(to: CGPoint(x: 50, y: 100))
	starPath.addLine(to: CGPoint(x: 60.26, y: 78.19))
	starPath.addLine(to: CGPoint(x: 82.14, y: 88.3))
	starPath.addLine(to: CGPoint(x: 75.98, y: 65))
	starPath.addLine(to: CGPoint(x: 99.24, y: 58.68))
	starPath.addLine(to: CGPoint(x: 79.54, y: 44.79))
	starPath.addLine(to: CGPoint(x: 93.3, y: 25))
	starPath.addLine(to: CGPoint(x: 69.28, y: 27.02))
	starPath.addLine(to: CGPoint(x: 67.1, y: 3.02))
	starPath.addLine(to: CGPoint(x: 50, y: 20))
	starPath.addLine(to: CGPoint(x: 32.9, y: 3.02))
	starPath.addLine(to: CGPoint(x: 30.72, y: 27.02))
	starPath.addLine(to: CGPoint(x: 6.7, y: 25))
	starPath.addLine(to: CGPoint(x: 20.46, y: 44.79))
	starPath.addLine(to: CGPoint(x: 0.76, y: 58.68))
	starPath.addLine(to: CGPoint(x: 24.02, y: 65))
	starPath.addLine(to: CGPoint(x: 17.86, y: 88.3))
	starPath.addLine(to: CGPoint(x: 39.74, y: 78.19))
	starPath.closeSubpath()
	return starPath
}()

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)

struct BindingsExampleBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			BindingsExampleBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
