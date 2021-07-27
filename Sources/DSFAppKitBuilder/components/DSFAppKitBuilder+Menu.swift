//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSMenu

/// A menu item
public class MenuItem {
	let menuItem = NSMenuItem()
	public init(title: String) {
		menuItem.title = title
	}
}

#if swift(<5.3)
@_functionBuilder
public struct MenuBuilder {
	static func buildBlock() -> [MenuItem] { [] }
}
#else
@resultBuilder
public struct MenuBuilder {
	static func buildBlock() -> [MenuItem] { [] }
}
#endif

/// A resultBuilder to build menus
public extension MenuBuilder {
	static func buildBlock(_ settings: MenuItem...) -> [MenuItem] {
		settings
	}
}
