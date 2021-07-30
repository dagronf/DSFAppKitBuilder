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

public class SplitView: Control {
	private let controller = NSSplitViewController(nibName: nil, bundle: nil)
	private lazy var splitView: NSSplitView = {
		controller.loadView()
		return controller.splitView
	}()
	
	override public var nsView: NSView { return self.splitView }

	let splitItems: [SplitViewItem]

	convenience public init(
		tag: Int? = nil,
		isVertical: Bool = true,
		dividerStyle: NSSplitView.DividerStyle? = nil,
		@SplitViewBuilder builder: () -> [SplitViewItem])
	{
		self.init(
			tag: tag,
			isVertical: isVertical,
			dividerStyle: dividerStyle,
			contents: builder())
	}

	internal init(
		tag: Int? = nil,
		isVertical: Bool = true,
		dividerStyle: NSSplitView.DividerStyle? = nil,
		contents: [SplitViewItem])
	{
		self.splitItems = contents
		super.init(tag: tag)

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

	private lazy var hiddenSplitBinder = Bindable<NSSet>()
	public func bindHiddenViews<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSSet>) -> Self {
		self.hiddenSplitBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			guard let `self` = self else { return }
			self.controller.splitViewItems.enumerated().forEach { item in
				item.1.isCollapsed = newValue.contains(item.0)
			}
		})
		self.hiddenSplitBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	/// This is a hack specifically for the split view - it seems like it doesn't handle the sizing
//	override public func addedToParentView(_ parentView: NSView) {
//		let which: NSLayoutConstraint.Attribute = splitView.isVertical ? .width : .height
//		let c = NSLayoutConstraint(item: splitView, attribute: which, relatedBy: .equal, toItem: parentView, attribute: which, multiplier: 1, constant: 0)
//		parentView.addConstraint(c)
//	}

}

/// MARK: Split View Item

public class SplitViewItem {
	// SplitViewController uses ViewControllers to manage the tabs.
	fileprivate class Controller: NSViewController {
		let content: Element

		let contentView = NSView()

		init(content: Element)
		{
			self.content = content

			contentView.addSubview(content.nsView)
			content.nsView.pinEdges(to: contentView)

			super.init(nibName: nil, bundle: nil)
		}

		@available(*, unavailable)
		required init?(coder _: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func loadView() {
			self.view = self.content.nsView
		}
	}

	fileprivate let viewController: Controller
	fileprivate let holdingPriority: NSLayoutConstraint.Priority?

	public init(
		holdingPriority: NSLayoutConstraint.Priority? = .defaultLow,
		content: Element)
	{
		self.viewController = SplitViewItem.Controller(content: content)
		self.holdingPriority = holdingPriority
	}
}

/// MARK: - Result Builder for SplitViewItems

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
