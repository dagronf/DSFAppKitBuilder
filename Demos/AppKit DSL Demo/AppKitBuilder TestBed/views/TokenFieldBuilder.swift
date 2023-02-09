//
//  TokenFieldBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 8/2/2023.
//

import Foundation
import AppKit
import DSFAppKitBuilder
import DSFValueBinders
import DSFMenuBuilder

class TokenFieldBuilder: ViewTestBed {
	var title: String { String.localized("Token Field") }
	var type: String { "TokenField" }
	var description: String { String.localized("A text field that converts text into visually distinct tokens.") }
	func build() -> ElementController {
		TokenFieldBuilderController()
	}
}

extension ValueBinder where ValueType == [String] {
	func stringValue() -> ValueBinder<String> {
		self.transform { "\($0)" }
	}
}

class TokenFieldBuilderController: ElementController {

	private let tokenField1 = ValueBinder<[String]>(["cat"])
	private let tokenField2 = ValueBinder<[String]>(["red", "green", "blue"])
	private let tokenField3 = ValueBinder<[String]>(["maroon"])
	private let tokenField4 = ValueBinder<[String]>([])
	private let tokenField5 = ValueBinder<[String]>(["pig", "fish", "elephant", "womble"])
	private let tokenField6 = ValueBinder<[String]>(["caterpillar@womble.com", "flutterby@womble.com"])

	lazy var body: Element = {
		VStack(spacing: 12, alignment: .leading) {
			FakeBox("TokenField update on end editing only") {
				TokenField(content: self.tokenField1, updateOnEndEditingOnly: true)
				HStack {
					Label("Tokens:").font(.system.bold())
					Label(self.tokenField1.stringValue())
					EmptyView()
				}
			}

			FakeBox(
				"TokenField update every change",
				VStack {
					TokenField(content: self.tokenField2)
						.completions { str in
							["red", "green", "blue", "yellow", "cyan", "magenta", "black"]
								.filter { $0.starts(with: str) }
						}
					HStack {
						Label("Tokens:").font(.system.bold())
						Label(self.tokenField2.stringValue())
						EmptyView()
					}
				}
				.hugging(h: 1)
				.edgeInsets(8)
			)

			FakeBox(
				"TokenField with completions (basic web color names)",
				VStack(alignment: .leading) {
					TokenField(tokenStyle: .rounded, content: self.tokenField3)
						.completions { str in
							colors.filter { $0.contains(str.lowercased()) }
						}
					HStack {
						Label("Tokens:").font(.system.bold())
						Label(self.tokenField3.stringValue())
					}
				}
				.hugging(h: 1)
				.edgeInsets(8)
			)

			FakeBox(
				"TokenField validating color names (basic web color names)",
				VStack(alignment: .leading) {
					TokenField(content: self.tokenField4)
						.completions { str in
							colors.filter { $0.contains(str.lowercased()) }
						}
						.shouldAddTokens { tokens, at in
							for token in tokens {
								if !colors.contains(token) {
									return []
								}
							}
							return tokens
						}
						.onEndEditingTokens { tokens in
							Swift.print("Tokens are now: \(tokens)")
						}
					HStack {
						Label("Tokens:").font(.system.bold())
						Label(self.tokenField4.stringValue())
					}
				}
				.hugging(h: 1)
				.edgeInsets(8)
			)

			FakeBox("TokenField with menus") {
				TokenField(content: self.tokenField6, updateOnEndEditingOnly: true)
					.hasMenuForToken { token in
						true
					}
					.menuForToken { token in
						Menu {
							MenuItem("Send email…")
								.onAction {
									let alert = NSAlert()
									alert.messageText = "Sending email to '\(token)'"
									alert.runModal()
								}
							MenuItem("Send file…")
								.onAction {
									let alert = NSAlert()
									alert.messageText = "Sending file to '\(token)'"
									alert.runModal()
								}
							Separator()
							MenuItem("Delete contact…")
								.onAction {
									let alert = NSAlert()
									alert.messageText = "Deleting contact '\(token)'"
									alert.runModal()
								}
						}
					}

				HStack {
					Label("Tokens:").font(.system.bold())
					Label(self.tokenField6.stringValue())
						.lineBreakMode(.byTruncatingTail)
						.wraps(true)
						.horizontalPriorities(hugging: 100, compressionResistance: 100)
					EmptyView()
				}
			}

			FakeBox("TokenField with large font") {
				TokenField(content: self.tokenField5, updateOnEndEditingOnly: true)
					.font(.title3.bold().condensed())
				HStack {
					Label("Tokens:").font(.system.bold())
					Label(self.tokenField5.stringValue())
						.lineBreakMode(.byTruncatingTail)
						.wraps(true)
						.horizontalPriorities(hugging: 100, compressionResistance: 100)
					EmptyView()
				}
			}
		}
		.hugging(h: 10)
	}()
}

// MARK: - A fake box

class FakeBox: Element {
	init(_ title: String, font: AKBFont? = nil, @ElementBuilder builder: () -> [Element]) {
		let font = font ?? AKBFont(NSFont.systemFont(ofSize: NSFont.smallSystemFontSize))
		self.body = VStack(spacing: 1, alignment: .leading) {
			Label(title)
				.labelPadding(NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 0))
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
		.hugging(h: 250)
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
		.hugging(h: 250)
		.accessibility([.group(title)])
	}

	let body: Element
	override func view() -> NSView { self.body.view() }
}

// MARK: - Color defs

fileprivate let colors: [String] = [
	"aliceblue",
	"antiquewhite",
	"aqua",
	"aquamarine",
	"azure",
	"beige",
	"bisque",
	"black",
	"blanchedalmond",
	"blue",
	"blueviolet",
	"brown",
	"burlywood",
	"cadetblue",
	"chartreuse",
	"chocolate",
	"coral",
	"cornflowerblue",
	"cornsilk",
	"crimson",
	"cyan",
	"darkblue",
	"darkcyan",
	"darkgoldenrod",
	"darkgray",
	"darkgreen",
	"darkgrey",
	"darkkhaki",
	"darkmagenta",
	"darkolivegreen",
	"darkorange",
	"darkorchid",
	"darkred",
	"darksalmon",
	"darkseagreen",
	"darkslateblue",
	"darkslategray",
	"darkslategrey",
	"darkturquoise",
	"darkviolet",
	"deeppink",
	"deepskyblue",
	"dimgray",
	"dimgrey",
	"dodgerblue",
	"firebrick",
	"floralwhite",
	"forestgreen",
	"fuchsia",
	"gainsboro",
	"ghostwhite",
	"gold",
	"goldenrod",
	"gray",
	"green",
	"greenyellow",
	"grey",
	"honeydew",
	"hotpink",
	"indianred",
	"indigo",
	"ivory",
	"khaki",
	"lavender",
	"lavenderblush",
	"lawngreen",
	"lemonchiffon",
	"lightblue",
	"lightcoral",
	"lightcyan",
	"lightgoldenrodyellow",
	"lightgray",
	"lightgreen",
	"lightgrey",
	"lightpink",
	"lightsalmon",
	"lightseagreen",
	"lightskyblue",
	"lightslategray",
	"lightslategrey",
	"lightsteelblue",
	"lightyellow",
	"lime",
	"limegreen",
	"linen",
	"magenta",
	"maroon",
	"mediumaquamarine",
	"mediumblue",
	"mediumorchid",
	"mediumpurple",
	"mediumseagreen",
	"mediumslateblue",
	"mediumspringgreen",
	"mediumturquoise",
	"mediumvioletred",
	"midnightblue",
	"mintcream",
	"mistyrose",
	"moccasin",
	"navajowhite",
	"navy",
	"oldlace",
	"olive",
	"olivedrab",
	"orange",
	"orangered",
	"orchid",
	"palegoldenrod",
	"palegreen",
	"paleturquoise",
	"palevioletred",
	"papayawhip",
	"peachpuff",
	"peru",
	"pink",
	"plum",
	"powderblue",
	"purple",
	"rebeccapurple",
	"red",
	"rosybrown",
	"royalblue",
	"saddlebrown",
	"salmon",
	"sandybrown",
	"seagreen",
	"seashell",
	"sienna",
	"silver",
	"skyblue",
	"slateblue",
	"slategray",
	"slategrey",
	"snow",
	"springgreen",
	"steelblue",
	"tan",
	"teal",
	"thistle",
	"tomato",
	"turquoise",
	"violet",
	"wheat",
	"white",
	"whitesmoke",
	"yellow",
	"yellowgreen",
]


#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct TokenFieldBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				TokenFieldBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
