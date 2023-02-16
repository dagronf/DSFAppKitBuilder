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
	var showContentInScroll: Bool { false }
	var description: String { String.localized("A ") }
	func build() -> ElementController {
		FlowLayoutBuilderController()
	}
}

class FlowLayoutBuilderController: ElementController {
	lazy var body: Element = {
		Flow {
			Button(title: "one")
			Label("This is a test!!").font(.title2)
				.truncatesLastVisibleLine(true)
				.horizontalCompressionResistancePriority(.defaultLow)
			Button(title: "two")
			VStack {
				RadioGroup {
					RadioElement("first")
					RadioElement("second")
					RadioElement("third")
				}
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
		.border(width: 0.5, color: .systemRed)
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