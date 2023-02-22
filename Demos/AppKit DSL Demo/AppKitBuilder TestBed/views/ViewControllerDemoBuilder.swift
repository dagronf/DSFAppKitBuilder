//
//  ViewControllerDemoBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 17/2/2023.
//

import Foundation
import AppKit

import Defaults

import DSFAppKitBuilder
import DSFValueBinders

public class ViewControllerDemoBuilder: ViewTestBed {
	var title: String { String.localized("View Controller demo") }
	var type: String { "" }
	var showContentInScroll: Bool { false }
	var description: String { String.localized("A simple example of wrapping a view with controlling logic within an NSViewController") }
	func build() -> ElementController {
		FirstLastNameViewController()
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ViewControllerDemoBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			ViewControllerDemoBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
