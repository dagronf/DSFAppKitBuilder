//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

public class Embedded: Element {

	let dsl: Element
	public override var nsView: NSView { return dsl.nsView }

	/// Create an element that contains another SwiftDSL element
	public init(tag: Int? = nil, dslElement: Element) {
		self.dsl = dslElement
		super.init(tag: tag)
	}
}
