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

public class BlankTemplateBuilder: ViewTestBed {
	var title: String { String.localized("Builder template") }
	var type: String { "The Element type" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("A description of the element") }
	func build() -> ElementController {
		BlankTemplateBuilderController()
	}
}

class BlankTemplateBuilderController: ElementController {
	lazy var body: Element = {
		Group(layoutType: .center) {
			// Fill in here
			Label("Content goes here")
		}
	}()
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct BlankTemplateBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			BlankTemplateBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
