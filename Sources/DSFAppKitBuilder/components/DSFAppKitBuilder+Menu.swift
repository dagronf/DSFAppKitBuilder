//
//  DSFAppKitBuilder+Menu.swift
//
//  Created by Darren Ford on 27/7/21
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

import AppKit.NSMenu

/// A menu item
public class MenuItem {
	let menuItem: NSMenuItem
	public init(title: String) {
		menuItem = NSMenuItem()
		menuItem.title = title
	}

	/// Make a menu divider item
	public static func Divider() -> MenuItem {
		return MenuItem()
	}

	public init() {
		menuItem = NSMenuItem.separator()
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
