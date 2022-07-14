//
//  DSFAppKitBuilder+TabView.swift
//
//  Created by Darren Ford on 28/7/21
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

import AppKit
import DSFValueBinders

/// Wrapper for NSSplitView
///
/// Usage:
///
/// ```swift
/// SplitView {
///    SplitViewItem {
///       VStack {
///          Label("1")
///       }
///       EmptyView()
///    }
///    SplitViewItem {
///       VStack {
///          Label("1")
///       }
///       EmptyView()
///    }
///    SplitViewItem {
///       VStack {
///          Label("1")
///       }
///       EmptyView(
///    }
/// }
public class SplitView: Control {

	/// Create a split view
	/// - Parameters:
	///   - isVertical: A Boolean value that determines the geometric orientation of the split view's dividers.
	///   - dividerStyle: The style of divider between views.
	///   - autosaveName: The name to use when the system automatically saves the split view’s divider configuration.
	///   - builder: The builder for generating the split items
	convenience public init(
		isVertical: Bool = true,
		dividerStyle: NSSplitView.DividerStyle? = nil,
		autosaveName: String? = nil,
		@SplitViewBuilder builder: () -> [SplitViewItem])
	{
		self.init(
			isVertical: isVertical,
			dividerStyle: dividerStyle,
			autosaveName: autosaveName,
			contents: builder())
	}

	deinit {
		self.hiddenSplitBinder?.deregister(self)
	}

	// Private

	private let splitItems: [SplitViewItem]
	public override func view() -> NSView { return self.splitView }
	public override func childElements() -> [Element] {
		return self.splitItems
			.map { $0.viewController.content }
	}

	private let controller = NSSplitViewController(nibName: nil, bundle: nil)
	private lazy var splitView: NSSplitView = {
		controller.loadView()
		return controller.splitView
	}()

	private var hiddenSplitBinder: ValueBinder<NSSet>?

	internal init(
		isVertical: Bool = true,
		dividerStyle: NSSplitView.DividerStyle? = nil,
		autosaveName: String? = nil,
		contents: [SplitViewItem])
	{
		self.splitItems = contents
		super.init()

		if let a = autosaveName {
			self.splitView.autosaveName = a
		}

		self.splitView.isVertical = isVertical

		self.splitView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.splitView.setContentHuggingPriority(.defaultLow, for: .vertical)

		if let s = dividerStyle { self.splitView.dividerStyle = s }
		contents.enumerated().forEach { item in
			let s = NSSplitViewItem(viewController: item.1.viewController)
			self.controller.addSplitViewItem(s)
			if let h = item.1.holdingPriority {
				s.holdingPriority = h
			}
		}
	}
}

// MARK: - Bindings

public extension SplitView {

	/// Bind the splitview item hidden status
	func bindHiddenViews(_ hiddenSplitBinder: ValueBinder<NSSet>) -> Self {
		self.hiddenSplitBinder = hiddenSplitBinder
		hiddenSplitBinder.register { [weak self] newValue in
			guard let `self` = self else { return }
			self.controller.splitViewItems.enumerated().forEach { item in
				item.1.isCollapsed = newValue.contains(item.0)
			}
		}
		return self
	}
}

// MARK: - Split View Item

/// A split view item
public class SplitViewItem {

	/// Create a split view item
	/// - Parameters:
	///   - holdingPriority: The holding priority to assign to this split item
	///   - builder: The builder for generating the split item's content
	convenience public init(
		holdingPriority: NSLayoutConstraint.Priority? = .defaultLow,
		builder: () -> Element) {
		self.init(
			holdingPriority: holdingPriority,
			content: builder()
		)
	}

	init(
		holdingPriority: NSLayoutConstraint.Priority? = .defaultLow,
		content: Element)
	{
		self.viewController = SplitViewItem.Controller(content: content)
		self.holdingPriority = holdingPriority
	}

	// Private
	fileprivate let viewController: Controller
	fileprivate let holdingPriority: NSLayoutConstraint.Priority?
}

// SplitViewController uses ViewControllers to manage the tabs.
private extension SplitViewItem {
	 class Controller: NSViewController {
		let content: Element
		let contentView = NSView()

		public init(content: Element)
		{
			self.content = content
			contentView.autoresizingMask = [.width, .height]
			contentView.addSubview(content.view())
			content.view().pinEdges(to: contentView)

			super.init(nibName: nil, bundle: nil)
		}

		@available(*, unavailable)
		required init?(coder _: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func loadView() {
			self.view = self.content.view()
		}
	}
}

// MARK: - Result Builder for SplitViewItems

#if swift(<5.3)
@_functionBuilder
public enum SplitViewBuilder {
	static func buildBlock() -> [SplitViewItem] { [] }
}
#else
@resultBuilder
public enum SplitViewBuilder {
	static func buildBlock() -> [SplitViewItem] { [] }
}
#endif

/// A resultBuilder to build menus
public extension SplitViewBuilder {
	static func buildBlock(_ settings: SplitViewItem...) -> [SplitViewItem] {
		settings
	}
}
