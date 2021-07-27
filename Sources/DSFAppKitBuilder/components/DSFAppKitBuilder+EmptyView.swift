//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSView

public class Empty: Element {
	let emptyView = NSView()
	override public var nsView: NSView { return emptyView }
	override public init(tag: Int? = nil) {
		super.init(tag: tag)
	}
}
