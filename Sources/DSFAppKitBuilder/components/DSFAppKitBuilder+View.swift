//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

/// Embed another NSView within the DSL
public class View: Element {
	let containedView: NSView
	override public var nsView: NSView { return containedView }

	public init(tag: Int? = nil, containedView: NSView) {
		self.containedView = containedView
		super.init(tag: tag)
	}
}
