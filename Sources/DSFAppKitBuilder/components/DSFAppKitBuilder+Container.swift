//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

public protocol DSFAppKitBuilderHandler {
	func rootElement() -> Element
}

/// Embed another DSL within this 
public class DSFAppKitBuilderView: NSView {

	public var dslContainer: DSFAppKitBuilderHandler? {
		didSet {
			self.dsl = dslContainer?.rootElement()
		}
	}

	private var dsl: Element? = nil {
		willSet {
			self.dsl?.nsView.removeFromSuperview()
		}
		didSet {
			if let d = dsl {
				self.addSubview(d.nsView)
				d.nsView.pinEdges(to: self)
			}
		}
	}
}
