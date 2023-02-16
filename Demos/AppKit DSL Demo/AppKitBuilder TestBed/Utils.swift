//
//  Utils.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 6/2/2023.
//

import Foundation

extension NumberFormatter {
	convenience init(_ builder: (NumberFormatter) -> Void) {
		self.init()
		builder(self)
	}
}

// MARK: - FakeBox

import AppKit
import DSFAppKitBuilder

class FakeBox: Element {
	init(_ title: String, font: AKBFont? = nil, @ElementBuilder builder: () -> [Element]) {
		let font = font ?? AKBFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize))
		self.body = VStack(spacing: 1, alignment: .leading) {
			Label(title)
				.labelPadding(NSEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
				.font(font)
				.applyStyle(Label.Styling.truncatingTail)
				.horizontalHuggingPriority(1)
			VStack(spacing: 8, alignment: .leading, elements: builder())
				.stackPadding(6)
				.cornerRadius(6)
				.border(width: 0.5, color: NSColor.quaternaryLabelColor)
				.backgroundColor(NSColor.quaternaryLabelColor.withAlphaComponent(0.05))
				.hugging(h: 1)
		}
		.hugging(h: 1)
		.accessibility([.group(title)])
	}

	init(_ title: String, font: AKBFont? = nil, _ content: Element) {
		let font = font ?? AKBFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize))
		self.body = VStack(spacing: 1, alignment: .leading) {
			Label(title)
				.labelPadding(NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 0))
				.font(font)
				.applyStyle(Label.Styling.truncatingTail)
				.horizontalHuggingPriority(1)
			content
				.cornerRadius(6)
				.border(width: 0.5, color: NSColor.quaternaryLabelColor)
				.backgroundColor(NSColor.quaternaryLabelColor.withAlphaComponent(0.05))
				.horizontalHuggingPriority(1)
		}
		.hugging(h: 1)
		.accessibility([.group(title)])
	}

	let body: Element
	override func view() -> NSView { self.body.view() }
}
