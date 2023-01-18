//
//  IdentityViewController.swift
//  DSFAppKitBuilderView Demo

import Foundation
import AppKit

import DSFAppKitBuilder

class IdentityViewController: DSFAppKitBuilderViewController {
	// Build the view's body
	override var viewBody: Element {
		HStack(spacing: 4) {
			ImageView()
				.image(NSImage(named: "apple_logo_orig")!)               // The image
				.size(width: 42, height: 42, priority: .required)        // fixed size
			VStack(spacing: 2, alignment: .leading) {
				Label("Apple Computer")                                  // The label with title 'Name'
					.font(NSFont.systemFont(ofSize: 24))                  // Font size 12
					.lineBreakMode(.byTruncatingTail)                     // Truncate line
					.horizontalPriorities(compressionResistance: 100)     // Allow the text field to compress
				Label("This is the description that can be quite long")  // The label with title 'Description'
					.font(NSFont.systemFont(ofSize: 12))                  // Font size 12
					.textColor(.placeholderTextColor)                     // Grey text
					.lineBreakMode(.byTruncatingTail)                     // Truncate line
					.horizontalPriorities(compressionResistance: 100)     // Allow the text field to compress
			}
		}
	}
}

#if canImport(SwiftUI)
import SwiftUI
struct DummyPreview: PreviewProvider {
	static var previews: some SwiftUI.View {
		IdentityViewController()
			.SwiftUIPreview()
			.frame(width: 280, height: 60)
			.padding()
	}
}
#endif
