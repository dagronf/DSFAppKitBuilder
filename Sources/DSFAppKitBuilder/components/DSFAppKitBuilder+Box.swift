//
//  DSFAppKitBuilder+Box.swift
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

import Foundation
import AppKit

public class Box: Element {
	private let boxView = NSBox()
	override public var nsView: NSView { return self.boxView }

	private let containerView = NSView()

	let content: Element

	internal init(
		tag: Int? = nil,
		_ title: String,
		titlePosition: NSBox.TitlePosition = .atTop,
		content: Element)
	{
		self.content = content
		super.init(tag: tag)

		// If we set the box's contentView to the nsView, the autolayout constraints gets all screwy
		boxView.contentView = containerView
		containerView.addSubview(content.nsView)
		content.nsView.pinEdges(to: containerView)

		boxView.title = title
		boxView.titlePosition = titlePosition
	}

	public convenience init(
		tag: Int? = nil,
		_ title: String,
		titlePosition: NSBox.TitlePosition = .atTop,
		_ builder: () -> Element) {
			self.init(tag: tag, title, titlePosition: titlePosition, content: builder())
	}

}

