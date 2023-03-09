//
//  Font.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

//  Font conveniences

import AppKit

/// A font definition
public class AKBFont {
	let font: NSFont
	public init(_ font: NSFont) {
		self.font = font
	}

	/// Return a copy of this font
	func copy() -> AKBFont { AKBFont(self.font.copy() as! NSFont) }
}

// MARK: Font variations

// To work around an issue with SwiftUI preview compilation failure
private let AKBFontZero = 0

public extension AKBFont {
	/// Returns a bold variant of the font
	func withSymbolicTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> AKBFont {
		var currentTraits = self.font.fontDescriptor.symbolicTraits
		currentTraits.insert(traits)
		let descriptor = self.font.fontDescriptor.withSymbolicTraits(currentTraits)
		if let font = NSFont(descriptor: descriptor, size: self.font.pointSize) {
			return AKBFont(font)
		}
		// Just return a copy of this font
		return self.copy()
	}

	/// Returns a bold variant of the font
	@inlinable func bold() -> AKBFont { self.withSymbolicTraits(.bold) }
	/// Returns a italic variant of the font
	@inlinable func italic() -> AKBFont { self.withSymbolicTraits(.italic) }
	/// Returns a expanded variant of the font
	@inlinable func expanded() -> AKBFont { self.withSymbolicTraits(.expanded) }
	/// Returns a expanded variant of the font
	@inlinable func condensed() -> AKBFont { self.withSymbolicTraits(.condensed) }

	/// Returns a weight variant of the font
	func weight(_ weight: NSFont.Weight) -> AKBFont {
		let fnt = self.addingAttributes([
			NSFontDescriptor.AttributeName.traits: [
				NSFontDescriptor.TraitKey.weight: weight.rawValue,
			],
		])
		return AKBFont(fnt)
	}

	/// Returns a version of the font with a specific font size
	func size(_ size: CGFloat) -> AKBFont {
		if let mf = NSFont(descriptor: self.font.fontDescriptor, size: size) {
			return AKBFont(mf)
		}
		return self.copy()
	}
}

// MARK: - Standard font definitions

// Inspiration: https://gist.github.com/shaps80/2d21b2ab92ea4fddd7b545d77a47024b
// Scaling values taken from Interface Builder

public extension AKBFont {
	/// The standard system font
	static let system = AKBFont(.systemFont(ofSize: NSFont.systemFontSize))								// 13
	/// A small system font
	static let systemSmall = AKBFont(.systemFont(ofSize: NSFont.smallSystemFontSize))
	/// System font at label size
	static let label = AKBFont(.systemFont(ofSize: NSFont.labelFontSize))
}

public extension AKBFont {
	/// The font you use for body text.
	static let body = AKBFont(.systemFont(ofSize: NSFont.systemFontSize))								// 13
	/// The font you use for callouts.
	static let callout = AKBFont(.systemFont(ofSize: NSFont.systemFontSize - 1))						// 12
	/// The font you use for standard captions.
	static let caption1 = AKBFont(.systemFont(ofSize: NSFont.systemFontSize - 3))						// 10
	/// The font you use for alternate captions.
	static let caption2 = AKBFont(.systemFont(ofSize: NSFont.systemFontSize - 2.5))					// Appears to be 10.5?
	/// The font you use in footnotes.
	static let footnote = AKBFont(.systemFont(ofSize: NSFont.systemFontSize - 4))						// 10?
	/// The font you use for headings.
	static let headline = AKBFont(.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold))	// 13
	/// The font you use for subheadings.
	static let subheadline = AKBFont(.systemFont(ofSize: NSFont.systemFontSize - 2))					// 11
	/// The font you use for large titles.
	static let largeTitle = AKBFont(.systemFont(ofSize: NSFont.systemFontSize + 13))					// 26
	/// The font you use for first-level hierarchical headings.
	static let title1 = AKBFont(.systemFont(ofSize: NSFont.systemFontSize + 9))						// 22
	/// The font you use for second-level hierarchical headings.
	static let title2 = AKBFont(.systemFont(ofSize: NSFont.systemFontSize + 4))						// 17
	/// The font you use for third-level hierarchical headings.
	static let title3 = AKBFont(.systemFont(ofSize: NSFont.systemFontSize + 2))						// 15
	/// A font with monospaced digits
	static let monospacedDigit = AKBFont(.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular))
	/// The font to use for monospaced text
	static let monospaced: AKBFont = {
		if #available(macOS 10.15, *) {
			return AKBFont(.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular))
		}
		else {
			let f = NSFont.systemFont(ofSize: NSFont.systemFontSize)
			let descriptor = f.fontDescriptor.withSymbolicTraits(.monoSpace)
			let mf = NSFont(descriptor: descriptor, size: NSFont.systemFontSize)!
			return AKBFont(mf)
		}
	}()
}

private extension AKBFont {
	func addingAttributes(_ attributes: [NSFontDescriptor.AttributeName: Any]) -> NSFont {
		NSFont(
			descriptor: self.font.fontDescriptor.addingAttributes(attributes),
			size: self.font.pointSize
		)!
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

fileprivate let _sampleText = "Sphinx of black quartz judge my vow 19.330"

@available(macOS 10.15, *)
struct FontPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			Group(layoutType: .center) {
				VStack(alignment: .leading) {
					HStack {
						Label("Plain text").font(.body)
						Label("Plain text").font(.body.size(14))
						Label("Plain text").font(.body.size(16))
						Label("Plain text").font(.body.size(18))
						Label("Plain text").font(.body.size(24))
					}

					HDivider()

					HStack {
						Label(".system").font(.system)
						VDivider()
						Label(".systemSmall").font(.systemSmall)
						VDivider()
						Label(".label").font(.label)
					}

					HDivider()
					HStack {
						Label("Plain text").font(.body)
						VDivider()
						Label("Bold text").font(.body.bold())
						VDivider()
						Label("Italic text").font(.body.italic())
						VDivider()
						Label("Bold Italic text").font(.body.bold().italic())
						VDivider()
						Label("Heavy text").font(.body.weight(.heavy))
						VDivider()
						Label("Black Italic text").font(.body.weight(.black).italic())
					}
					HStack {
						Label("Monospaced").font(.monospaced)
						VDivider()
						Label("Monospaced Bold").font(.monospaced.bold())
					}

					HStack {
						Label("standard").font(.title2)
						VDivider()
						Label("expanded").font(.title2.expanded())
						VDivider()
						Label("condensed").font(.title2.condensed())
					}
					HDivider()
					Grid {
						GridRow(rowAlignment: .firstBaseline) {
							Label("Style").font(.title3.bold())
							Label("Preview").font(.title3.bold())
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".body").font(.monospaced)
							Label(_sampleText).font(.body)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".callout").font(.monospaced)
							Label(_sampleText).font(.caption1)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".caption1").font(.monospaced)
							Label(_sampleText).font(.caption1)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".footnote").font(.monospaced)
							Label(_sampleText).font(.footnote)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".headline").font(.monospaced)
							Label(_sampleText).font(.headline)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".subheadline").font(.monospaced)
							Label(_sampleText).font(.subheadline)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".system").font(.monospaced)
							Label(_sampleText).font(.system)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".largeTitle").font(.monospaced)
							Label(_sampleText).font(.largeTitle)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".title1").font(.monospaced)
							Label(_sampleText).font(.title1)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".title2").font(.monospaced)
							Label(_sampleText).font(.title2)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".title3").font(.monospaced)
							Label(_sampleText).font(.title3)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".monospacedDigit").font(.monospaced)
							Label(_sampleText).font(.monospacedDigit)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".monospaced").font(.monospaced)
							Label(_sampleText).font(.monospaced)
						}
					}
					HDivider()
					HStack {
						Button(title: "Pressable!")
						Button(title: "Pressable!").font(.system.bold())
						Button(title: "Pressable!").font(.system.italic())
						VDivider()
						CheckBox("Checkbox!").font(.system.italic())
						CheckBox("Checkbox!").font(.system.bold())
					}
				}
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}

#endif
