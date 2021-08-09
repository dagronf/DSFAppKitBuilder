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
	/// Create a tab view element
	/// - Parameters:
	///   - tabViewType: The tab type to display the tabs.
	///   - selectedIndex: The initially selected tab index
	///   - builder: The builder for generating the tabviewitems
	public convenience init(
		tabViewType: NSTabView.TabType? = nil,
		tabPosition: NSTabView.TabPosition? = nil,
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
		tabPosition: NSTabView.TabPosition? = nil,
		selectedIndex: Int = 0,
		contents: [TabViewItem]
	) {
		super.init()

		if let type = tabViewType {
			self.tabView.tabViewType = type
		}

		if let tabPos = tabPosition {
			self.tabView.tabPosition = tabPos
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

	// Private
	private let tabView = NSTabView()
	override public var nsView: NSView { return self.tabView }

	private lazy var valueBinder = Bindable<Int>()
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
	/// Bind the selected segments to a keypath
	func bindTabIndex<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Int>) -> Self {
		self.valueBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.tabView.selectTabViewItem(at: newValue)
		})
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
			self.valueBinder.setValue(index)
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
			container.addSubview(self.content.nsView)

			self.content.nsView.pinEdges(to: container)

			self.view = container
		}
	}
}

// MARK: - Result Builders for Tab Views

#if swift(<5.3)
@_functionBuilder
public enum TabBuilder {
	static func buildBlock() -> [Tab] { [] }
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
