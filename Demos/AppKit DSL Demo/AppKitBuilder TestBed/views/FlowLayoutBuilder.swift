//
//  FlowLayoutBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 15/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class FlowLayoutBuilder: ViewTestBed {
	var title: String { String.localized("Flow layout") }
	var type: String { "Flow" }
	//var showContentInScroll: Bool { false }
	var description: String { String.localized("In a flow layout, the first item is positioned in the top-left corner and other items are laid out horizontally, wrapping when there's not enough horizontal room.") }
	func build() -> ElementController {
		FlowLayoutBuilderController()
	}
}

class FlowLayoutBuilderController: ElementController {
	let radioHidden = ValueBinder(false)

	lazy var body: Element = {
		VStack(alignment: .leading) {
			FakeBox("Hashtags (left-aligned)") {
				Flow(
					minimumInteritemSpacing: 4,
					minimumLineSpacing: 4,
					layoutDirection: .leftToRight
				) {
					FlatButton(title: "#earth")
					FlatButton(title: "#universe")
					FlatButton(title: "#space")
					FlatButton(title: "#black_hole")
					FlatButton(title: "#astronomical")
					FlatButton(title: "#planetary")
				}
			}
			.horizontalHuggingPriority(1)

			FakeBox("Hashtags (right-aligned)") {
				Flow(
					minimumInteritemSpacing: 4,
					minimumLineSpacing: 4,
					layoutDirection: .rightToLeft
				) {
					FlatButton(title: "#earth")
					FlatButton(title: "#universe")
					FlatButton(title: "#space")
					FlatButton(title: "#black_hole")
					FlatButton(title: "#astronomical")
					FlatButton(title: "#planetary")
				}
			}
			.horizontalHuggingPriority(1)

			FakeBox("Hashtags (user-interface direction)") {
				Flow(
					minimumInteritemSpacing: 4,
					minimumLineSpacing: 4
				) {
					Button(title: "#earth", bezelStyle: .roundRect)
					Button(title: "#universe", bezelStyle: .roundRect)
					Button(title: "#space", bezelStyle: .roundRect)
					Button(title: "#black_hole", bezelStyle: .roundRect)
					Button(title: "#astronomical", bezelStyle: .roundRect)
					Button(title: "#planetary", bezelStyle: .roundRect)
				}
			}
			.horizontalHuggingPriority(1)

			HDivider()

			Flow(edgeInsets: NSEdgeInsets(edgeInset: 20)) {
				Button(title: "one")
				Label("This is a test!!").font(.title2)
					.truncatesLastVisibleLine(true)
					.horizontalCompressionResistancePriority(.defaultLow)
				Button(title: "two")
				Toggle()
					.bindOnOff(radioHidden)
				VStack {
					RadioGroup {
						RadioElement("first")
						RadioElement("second")
						RadioElement("third")
					}
					.bindIsHidden(radioHidden)
				}
				Button(title: "four")
				Button(title: "five")

				Label("Plain text").font(.body)
				Label("Bold text").font(.body.bold())
				Label("Italic text").font(.body.italic())
				Label("Bold Italic text").font(.body.bold().italic())
				Label("Heavy text").font(.body.weight(.heavy))
				Label("Black Italic text").font(.body.weight(.black).italic())
				VStack(alignment: .leading) {
					Label("Monospaced").font(.monospaced)
					Label("Monospaced Bold").font(.monospaced.bold())
				}
			}
			.cornerRadius(8)
			.backgroundColor(.systemOrange.withAlphaComponent(0.05))
			.border(width: 0.5, color: .systemRed)
		}
		.hugging(h: 10)
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct FlowLayoutBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				FlowLayoutBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
