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

/// A Tab View control
///
/// Usage:
///
/// ```swift
/// TabView {
///    TabViewItem("First") {
///       VStack {
///          Label("Tab View 1")
///       }
///    }
///    TabViewItem("Second") {
///       VStack {
///          Label("Tab View 2")
///       }
///    }
///    TabViewItem("Third") {
///       VStack {
///          Label("Tab View 3")
///       }
///    }
/// }
/// ```
///
public class TabView: Control {

	/// Position wrapper
	public enum Position: Int {
		 case none = 0
		 case top = 1
		 case left = 2
		 case bottom = 3
		 case right = 4

		@available(macOS 10.12, *)
		var nsTabPosition: NSTabView.TabPosition? {
			return NSTabView.TabPosition(rawValue: UInt(self.rawValue))
		}
	}

	/// Create a tab view element
	/// - Parameters:
	///   - tabViewType: The tab type to display the tabs.
	///   - selectedIndex: The initially selected tab index
	///   - builder: The builder for generating the tabviewitems
	public convenience init(
		tabViewType: NSTabView.TabType? = nil,
		tabPosition: TabView.Position? = nil,
		selectedIndex: Int = 0,
		@TabBuilder builder: () -> [TabViewItem]
	) {
		self.init(
			tabViewType: tabViewType,
			tabPosition: tabPosition,
			selectedIndex: selectedIndex,
			contents: builder()
		)
	}

	init(
		tabViewType: NSTabView.TabType? = nil,
		tabPosition: TabView.Position? = nil,
		selectedIndex: Int = 0,
		contents: [TabViewItem]
	) {
		super.init()

		if let type = tabViewType {
			self.tabView.tabViewType = type
		}

		if let tabPos = tabPosition {
			if #available(macOS 10.12, *) {
				self.tabView.tabPosition = tabPos.nsTabPosition ?? .top
			} else {
				// Fallback on earlier versions
			}
		}

		contents.forEach { item in
			let t = NSTabViewItem(viewController: item.viewController)
			t.label = item.title ?? ""
			t.toolTip = item.toolTip
			t.view?.needsLayout = true

			self.tabView.addTabViewItem(t)
		}

		self.tabView.selectTabViewItem(at: selectedIndex)
		self.tabView.delegate = self

		self.tabView.needsLayout = true
		self.tabView.needsDisplay = true
	}

	deinit {
		self.tabIndexBinder?.deregister(self)
	}

	// Private
	private let tabView = NSTabView()
	public override func view() -> NSView { return self.tabView }

	private var tabIndexBinder: ValueBinder<Int>?
	private var changeBlock: ((Int) -> Void)?
}

// MARK: - Actions

public extension TabView {

	/// Set a block to be called when the tab changes
	func onChange(_ changeBlock: @escaping (Int) -> Void) -> Self {
		self.changeBlock = changeBlock
		return self
	}
}

// MARK: - Bindings

public extension TabView {
	/// Bind the selected segments
	func bindTabIndex(_ tabIndexBinder: ValueBinder<Int>) -> Self {
		self.tabIndexBinder = tabIndexBinder
		tabIndexBinder.register { [weak self] newValue in
			self?.tabView.selectTabViewItem(at: newValue)
		}
		return self
	}
}

// MARK: - NSTabViewDelegate

extension TabView: NSTabViewDelegate {
	public func tabView(_: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		if let item = tabViewItem {
			let index = self.tabView.indexOfTabViewItem(item)
			item.view?.needsUpdateConstraints = true
			self.changeBlock?(index)

			// Tell the binder to update its value
			self.tabIndexBinder?.wrappedValue = index
		}
	}
}

// MARK: - Tab Item

/// An individual tab item
public class TabViewItem {
	/// Create a TabViewItem using a resultBuilder
	/// - Parameters:
	///   - title: The title to use for the tab item
	///   - toolTip: The tooltip to use for the tab item
	///   - builder: The builder for generating the tab item content
	public convenience init(_ title: String? = nil, toolTip: String? = nil, _ builder: () -> Element) {
		self.init(
			title,
			toolTip: toolTip,
			content: builder()
		)
	}

	/// Create a TabViewItem
	init(_ title: String? = nil, toolTip: String? = nil, content: Element) {
		self.title = title
		self.toolTip = toolTip
		self.viewController = TabViewItem.Controller(content: content)
	}

	// Private
	fileprivate let title: String?
	fileprivate let toolTip: String?
	fileprivate let viewController: Controller
}

private extension TabViewItem {
	// TabView uses ViewControllers to manage the tabs.
	class Controller: NSViewController {
		private let content: Element

		init(content: Element) {
			self.content = content
			super.init(nibName: nil, bundle: nil)
		}

		@available(*, unavailable)
		required init?(coder _: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func loadView() {
			// The NSTabView item doesn't seem to layout well if the tab item's container is autolayout
			// Wrap our element in a non-autolayout NSView first
			let container = NSView()
			container.translatesAutoresizingMaskIntoConstraints = true
			container.autoresizingMask = [.width, .height]
			container.addSubview(self.content.view())

			self.content.view().pinEdges(to: container)

			self.view = container
		}
	}
}

// MARK: - Result Builders for Tab Views

#if swift(<5.3)
@_functionBuilder
public enum TabBuilder {
	static func buildBlock() -> [TabViewItem] { [] }
}
#else
@resultBuilder
public enum TabBuilder {
	static func buildBlock() -> [TabViewItem] { [] }
}
#endif

/// A resultBuilder to build menus
public extension TabBuilder {
	static func buildBlock(_ settings: TabViewItem...) -> [TabViewItem] {
		settings
	}
}
