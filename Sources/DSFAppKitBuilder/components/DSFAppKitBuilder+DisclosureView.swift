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
	/// Create a disclosure view
	/// - Parameters:
	///   - title: The title
	///   - titleFont: The font to use for the title
	///   - initialExpansionState: The initial state for the disclosure
	///   - header: The Element to use in the header of the disclosure view
	///   - builder: The content to display in the disclosure view
	convenience public init(
		title: String,
		titleFont: AKBFont? = nil,
		headerHeight: Double? = nil,
		initiallyExpanded: Bool = true,
		header: (() -> Element)? = nil,
		_ builder: () -> Element
	) {
		self.init(
			title: title,
			titleFont: titleFont,
			headerHeight: headerHeight,
			initiallyExpanded: initiallyExpanded,
			isExpandedBinder: nil,
			header: header,
			builder
		)
	}

	/// Create a disclosure view
	/// - Parameters:
	///   - title: The title
	///   - titleFont: The font to use for the title
	///   - isExpandedBinder: A ValueBinder for hiding/expanding the disclosure view
	///   - header: The Element to use in the header of the disclosure view
	///   - builder: The content to display in the disclosure view
	convenience public init(
		title: String,
		titleFont: AKBFont? = nil,
		headerHeight: Double? = nil,
		isExpandedBinder: ValueBinder<Bool>,
		header: (() -> Element)? = nil,
		_ builder: () -> Element
	) {
		self.init(
			title: title,
			titleFont: titleFont,
			headerHeight: headerHeight,
			initiallyExpanded: false,
			isExpandedBinder: isExpandedBinder,
			header: header,
			builder
		)
	}

	// Create a disclosure view
	// - Parameters:
	//   - title: The title
	//   - titleFont: The font to use for the title
	//   - initialExpansionState: The initial state for the disclosure
	//   - isExpandedBinder: A ValueBinder for hiding/expanding the disclosure view
	//   - header: The Element to use in the header of the disclosure view
	//   - builder: The content to display in the disclosure view
	internal init(
		title: String,
		titleFont: AKBFont? = nil,
		headerHeight: Double? = nil,
		initiallyExpanded: Bool = true,
		isExpandedBinder: ValueBinder<Bool>? = nil,
		header: (() -> Element)? = nil,
		_ builder: () -> Element
	) {
		self.title = title
		self.titleFont = titleFont ?? AKBFont.headline.weight(.bold)
		self.initiallyExpanded = initiallyExpanded
		self.childElement = builder()
		self.headerElement = header?()
		self.headerHeight = headerHeight
		super.init()

		if let isExpandedBinder = isExpandedBinder {
			_ = self.bindIsExpanded(isExpandedBinder)
		}
	}

	private lazy var rootElement: Element = {

		var hstackBinder: NSStackView?

		let disclosure: Element =
			VStack(spacing: 8, alignment: .leading, distribution: .fill) {
				HStack(spacing: 4, alignment: .centerY)  {
					Button(title: "", type: .onOff, bezelStyle: .disclosure)
						.state(self.initiallyExpanded ? .on : .off)
						.bindElement(self.disclosureButtonBinder)
						.onChange { [weak self] newState in
							self?.updateState(newState)
						}
					Label(self.title).font(self.titleFont)
						.onLabelClicked { [weak self] in
							self?.toggleState()
						}
					EmptyView()
						.horizontalHuggingPriority(10)
					Maybe(self.headerElement)
				}
				.edgeInsets(right: 4)
				.hugging(h: 10)
				.verticalCompressionResistancePriority(.defaultHigh)
				.bindControl(to: &hstackBinder)

				self.childElement
			}
			.detachesHiddenViews()

		if let forcedHeight = self.headerHeight, let binder = hstackBinder {
			let c = binder.heightAnchor.constraint(equalToConstant: forcedHeight)
			c.priority = .defaultLow
			c.isActive = true
			//hstackBinder?.heightAnchor.constraint(equalToConstant: forcedHeight).isActive = true
		}

		self.updateState(self.initiallyExpanded ? .on : .off)

		return disclosure
	}()

	override public func view() -> NSView { return self.rootElement.view() }

	deinit {
		self.isEnabledBinder?.deregister(self)
		self.isExpandedBinder?.deregister(self)
	}

	private let title: String
	private let titleFont: AKBFont
	private let initiallyExpanded: Bool
	private let headerHeight: Double?

	private var isExpandedBinder: ValueBinder<Bool>?
	private var isEnabledBinder: ValueBinder<Bool>?

	private let disclosureButtonBinder = ElementBinder()
	private var isUpdatingState: Bool = false

	private let childElement: Element
	private let headerElement: Element?
}

public extension DisclosureView {
	/// Set the tooltip to use for the disclosure button (the little '>' and '∨' button)
	@discardableResult func disclosureTooltip(_ tooltip: String) -> Self {
		self.underlyingAppKitButton().toolTip = tooltip
		return self
	}
}

// MARK: - Bindings

public extension DisclosureView {
	/// Bind the expanded state to a ValueBinder
	@discardableResult func bindIsExpanded(_ stateBinder: ValueBinder<Bool>) -> Self {
		self.isExpandedBinder = stateBinder
		stateBinder.register(self) { [weak self] newValue in
			self?.updateState(newValue ? .on : .off)
		}

		// Bind the disclosure button to the state binder as well
		guard let b = disclosureButtonBinder.element as? Button else { fatalError() }
		b.bindOnOffState(stateBinder)
		return self
	}

	/// Bind the enabled state for the disclosure view
	@discardableResult func bindIsEnabled(_ isEnabledBinder: ValueBinder<Bool>) -> Self {
		self.isEnabledBinder = isEnabledBinder
		isEnabledBinder.register(self) { [weak self] newValue in
			self?.underlyingAppKitButton().isEnabled = newValue
		}
		return self
	}
}

// MARK: Private methods

private extension DisclosureView {
	private func underlyingAppKitButton() -> NSButton {
		guard
			let e = disclosureButtonBinder.element as? Button,
			let b = e.view() as? NSButton
		else {
			fatalError("INTERNAL ERROR: Underlying disclosure button type is not button!")
		}
		return b
	}

	private func toggleState() {
		self.underlyingAppKitButton().performClick(self)
	}

	private func updateState(_ newState: NSControl.StateValue) {
		assert(Thread.isMainThread)
		if !isUpdatingState {
			self.isUpdatingState = true
			let isExpanded = (newState != .off)
			self.childElement.view().isHidden = !isExpanded
			self.isExpandedBinder?.wrappedValue = isExpanded

			// If a header element was specified, hide it if we are expanded
			self.headerElement?.view().isHidden = isExpanded

			self.isUpdatingState = false
		}
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct DisclosureViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			SplitView {
				SplitViewItem {
					VStack {
						Label("title")
						HStack {
							DisclosureView(title: "Format", header: {
								Button(title: "Reset").controlSize(.small)
							}) {
								HStack {
									Label("Format style!")
										.horizontalHuggingPriority(.init(10))
									Toggle()
								}
							}
							.border(width: 1, color: NSColor.green)
							.backgroundColor(NSColor.green.withAlphaComponent(0.2))

							DisclosureView(title: "Style") {
								HStack {
									Label("Style style!")
										.horizontalHuggingPriority(.init(10))
									Toggle()
								}
							}
							.border(width: 1, color: NSColor.red)
							.backgroundColor(NSColor.red.withAlphaComponent(0.2))

							EmptyView()
						}
						.edgeInsets(12)
						EmptyView()
					}
				}
				SplitViewItem {
					VStack {
						DisclosureView(title: "Format", headerHeight: 28) {
							HStack {
								Label("Format style!")
									.horizontalHuggingPriority(.init(10))
								Toggle()
							}
						}
						.border(width: 1, color: NSColor.green)
						.backgroundColor(NSColor.green.withAlphaComponent(0.2))

						HDivider()

						DisclosureView(title: "Style", headerHeight: 28) {
							HStack {
								Label("Style style!")
									.horizontalHuggingPriority(.init(10))
								Toggle()
							}
						}
						.border(width: 1, color: NSColor.red)
						.backgroundColor(NSColor.red.withAlphaComponent(0.2))

						HDivider()
						EmptyView()
					}
					.edgeInsets(12)
				}
			}

			.SwiftUIPreview()
		}
	}
}
#endif
