//
//  DSFAppKitBuilder+DisclosureView.swift
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
import DSFValueBinders

public class DisclosureView: Element {

	public init(
		title: String,
		titleFont: AKBFont? = nil,
		initialState: NSControl.StateValue = .on,
		isExpandedBinder: ValueBinder<Bool>? = nil,
		_ builder: () -> Element
	) {
		self.title = title
		self.titleFont = titleFont ?? AKBFont.headline.weight(.bold)
		self.initialState = initialState
		self.childElements = builder()

		super.init()

		if let isExpandedBinder = isExpandedBinder {
			_ = self.bindIsExpanded(isExpandedBinder)
		}
	}

	private lazy var rootElement: Element = {
		let disclosure: Element =
		VStack(spacing: 8, alignment: .leading, distribution: .fill) {
			HStack(spacing: 4, alignment: .lastBaseline)  {
				Button(title: "", type: .onOff, bezelStyle: .disclosure)
					.state(self.initialState)
					.bindElement(self.disclosureButtonBinder)
					.onChange { [weak self] newState in
						self?.updateState(newState)
					}
				Label(self.title).font(self.titleFont)
					.horizontalHuggingPriority(1)
					.onLabelClicked { [weak self] in
						self?.toggleState()
					}
			}
			.hugging(h: 1)

			self.childElements
		}
		.detachesHiddenViews()

		self.updateState(self.initialState)

		return disclosure
	}()

	private func toggleState() {
		guard
			let e = disclosureButtonBinder.element as? Button,
			let b = e.view() as? NSButton
		else {
			fatalError()
		}
		b.performClick(self)
	}

	private func updateState(_ newState: NSControl.StateValue) {
		assert(Thread.isMainThread)
		if !isUpdatingState {
			self.isUpdatingState = true
			let isExpanded = (newState != .off)
			self.childElements.view().isHidden = !isExpanded
			self.isExpandedBinder?.wrappedValue = isExpanded
			self.isUpdatingState = false
		}
	}

	override public func view() -> NSView { return self.rootElement.view() }

	private let title: String
	private let titleFont: AKBFont
	private let initialState: NSControl.StateValue
	private var titleBinder: ValueBinder<String>?
	private var isExpandedBinder: ValueBinder<Bool>?

	private let disclosureButtonBinder = ElementBinder()
	private var isUpdatingState: Bool = false

	private let childElements: Element
}

// MARK: - Bindings

public extension DisclosureView {
	/// Bind the expanded state to a ValueBinder
	@discardableResult func bindIsExpanded(_ stateBinder: ValueBinder<Bool>) -> Self {
		self.isExpandedBinder = stateBinder
		stateBinder.register { [weak self] newValue in
			self?.updateState(newValue ? .on : .off)
		}

		// Bind the disclosure button to the state binder as well
		guard let b = disclosureButtonBinder.element as? Button else { fatalError() }
		b.bindOnOffState(stateBinder)
		return self
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct DisclosureViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				DisclosureView(title: "Format") {
					HStack {
						Label("Format style!")
							.horizontalHuggingPriority(.init(10))
						Toggle()
					}
				}
				.border(width: 1, color: NSColor.green)

				HDivider()

				DisclosureView(title: "Style") {
					HStack {
						Label("Style style!")
							.horizontalHuggingPriority(.init(10))
						Toggle()
					}
				}
				.border(width: 1, color: NSColor.green)

				HDivider()
				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
