//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSBox

public class Divider: Element {

	public enum Direction {
		case horizontal
		case vertical
	}


	/// Create a divider
	/// - Parameters:
	///   - tag: (optional) The identifing tag
	///   - direction: The direction
	public init(tag: Int? = nil, direction: Direction) {
		if direction == .horizontal {
			separator = NSBox(frame: NSRect(x: 0, y: 0, width: 50, height: 5))
		}
		else {
			separator = NSBox(frame: NSRect(x: 0, y: 0, width: 5, height: 50))
		}
		super.init(tag: tag)
		separator.boxType = .separator
		if direction == .horizontal {
			_ = self.contentHugging(h: .defaultLow)
		}
		else {
			_ = self.contentHugging(v: .defaultLow)
		}
	}

	// Privates

	private let separator: NSBox
	public override var nsView: NSView { return separator }
}
