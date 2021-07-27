//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSPopUpButton

public class PopupButton: Control {
	public override var nsView: NSView { return self.popupButton }
	let popupButton = NSPopUpButton()
	let content: [MenuItem]

	internal init(tag: Int? = nil, pullsDown: Bool = false, _ content: [MenuItem]) {
		self.content = content
		super.init(tag: tag)

		self.popupButton.pullsDown = pullsDown
		let menu = NSMenu()
		content.forEach {
			$0.menuItem.target = self
			$0.menuItem.action = #selector(selectionChanged(_:))
			menu.addItem($0.menuItem)
		}
		self.popupButton.menu = menu
	}

	public convenience init(
		tag: Int? = nil,
		pullsDown: Bool = false,
		@MenuBuilder builder: () -> [MenuItem]
	) {
		self.init(
			tag: tag,
			pullsDown: pullsDown,
			builder())
	}

	public func selectItem(at index: Int) -> Self {
		self.popupButton.selectItem(at: index)
		return self
	}

	public var selectedIndex: Int {
		return self.popupButton.indexOfSelectedItem
	}

	var selectionChangeBlock: ((PopupButton) -> Void)? = nil
	public func onChange(_ block: @escaping (PopupButton) -> Void) -> Self{
		self.selectionChangeBlock = block
		return self
	}

	@objc func selectionChanged(_ sender: Any) {
		self.selectionChangeBlock?(self)
	}
}
