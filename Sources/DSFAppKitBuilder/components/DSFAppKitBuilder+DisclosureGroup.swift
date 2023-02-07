//
//  DSFAppKitBuilder+DisclosureGroup.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
import Foundation
import AppKit

// MARK: - Disclosure Group

/// An element that contains a collection of `DisclosureView`s
public class DisclosureGroup: Element {
	/// Create a vertical disclosure group (a stack of disclosure views)
	/// - Parameters:
	///   - builder: The builder for generating the group of radio elements
	public init(
		label: String? = nil,
		spacing: CGFloat = 12,
		showSeparators: Bool = true,
		@DisclosureGroupBuilder builder: () -> [DisclosureView]
	) {
		let elements = builder()
		var contents = [Element]()
		elements.forEach { view in
			contents.append(view)
			if showSeparators {
				contents.append(HDivider())
			}
		}

		let stack = VStack(orientation: .vertical, alignment: .leading, content: contents)
			.spacing(spacing)

		if let label = label {
			// If a label was set, mark the view as an accessibility group with a label
			_ = stack.accessibility([.group(label)])
		}

		self.rootStack = stack

		super.init()
	}

	let rootStack: VStack
	override public func view() -> NSView { return self.rootStack.view() }
}

@resultBuilder
public enum DisclosureGroupBuilder {
	static func buildBlock() -> [DisclosureView] { [] }
}

/// A resultBuilder to build menus
public extension DisclosureGroupBuilder {
	static func buildBlock(_ settings: DisclosureView...) -> [DisclosureView] {
		settings
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct DisclosureGroupPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			ScrollView(fitHorizontally: true) {
				DisclosureGroup {
					DisclosureView(title: "Formatting", initiallyExpanded: false) {
						Label("First one!")
							.horizontalHuggingPriority(.init(10))
					}
					DisclosureView(title: "Spacing", initiallyExpanded: true) {
						VStack {
							HStack {
								Label("Slidey!")
									.horizontalHuggingPriority(.init(10))
								Slider(range: 0 ... 100, value: 65)
							}
							HStack {
								Label("Activatey?")
									.horizontalHuggingPriority(.init(10))
								Toggle()
							}
						}
					}
				}
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
