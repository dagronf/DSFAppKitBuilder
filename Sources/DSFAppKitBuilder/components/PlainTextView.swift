//
//  TextView.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit
import Foundation

import DSFValueBinders

public extension NSTextView {
	func wrapText(_ isWrapped: Bool) {
		guard let scrollView = enclosingScrollView else { return }
		
		scrollView.hasHorizontalScroller = !isWrapped
		self.isHorizontallyResizable = !isWrapped

		scrollView.hasVerticalScroller = true

		let width = isWrapped ? scrollView.contentSize.width : CGFloat.greatestFiniteMagnitude
		self.maxSize = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)

		self.textContainer?.size = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		self.textContainer?.widthTracksTextView = isWrapped

		if isWrapped {
			self.autoresizingMask = [.width]
		}
		else {
			self.autoresizingMask = [.width, .height]
		}

		if isWrapped {
			self.setFrameSize(NSSize(width: width, height: scrollView.contentSize.height))
		}

		self.invalidateTextContainerOrigin()
	}
}

public class PlainTextView: Element {
	public init(
		text: ValueBinder<String>,
		borderType: NSBorderType? = nil,
		wrapsLines: Bool = true
	) {
		self.textBinder = text

		super.init()

		// Setup NSTextView
		textView.wantsLayer = true
		textView.delegate = self
		textView.isRichText = false
		textView.autoresizingMask = [.width] //, .height]
		textView.isEditable = true

		scrollView.wantsLayer = true
		scrollView.documentView = textView
		scrollView.hasVerticalScroller = true
		if let borderType = borderType {
			scrollView.borderType = borderType
		}

		if #available(macOS 10.14, *) {
			 textView.usesAdaptiveColorMappingForDarkAppearance = true
		} else {
			 // Fallback on earlier versions - do nothing
		}

		self.textBinder.register(self) { [weak self] newText in
			guard let `self` = self else { return }
			if !self.isUpdating {
				self.isUpdating = true
				self.textView.string = newText
				self.isUpdating = false
			}
		}

		self.configure(wrapsLines: wrapsLines)
	}

	private func configure(wrapsLines: Bool) {
		self.textView.wrapText(wrapsLines)
	}

	deinit {
		self.wrapsBinder?.deregister(self)
		self.wrapsBinder = nil
	}

	private let scrollView = NSScrollView()
	private let textView = NSTextView()
	private let textBinder: ValueBinder<String>
	private var wrapsBinder: ValueBinder<Bool>?
	private var isUpdating = false

	override public func view() -> NSView { self.scrollView }
}

extension PlainTextView: NSTextViewDelegate {
	public func textDidChange(_ notification: Notification) {
		if !self.isUpdating {
			self.isUpdating = true
			self.textBinder.wrappedValue = self.textView.string
			self.isUpdating = false
		}
	}
}

public extension PlainTextView {

	@discardableResult func isEditable(_ editable: Bool) -> Self {
		self.textView.isEditable = editable
		return self
	}

	@discardableResult func isSelectable(_ selectable: Bool) -> Self {
		self.textView.isSelectable = selectable
		return self
	}

	@discardableResult func font(_ font: AKBFont) -> Self {
		self.textView.font = font.font
		return self
	}

	/// 
	@discardableResult func font(_ font: NSFont) -> Self {
		self.textView.font = font
		return self
	}

	@discardableResult func bindWrapsText(_ binder: ValueBinder<Bool>) -> Self {
		self.wrapsBinder = binder
		binder.register(self) { [weak self] newValue in
			self?.configure(wrapsLines: newValue)
		}
		return self
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

private let _textValue = ValueBinder(__dummyText)

@available(macOS 10.15, *)
struct WrappingTextViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			Group {
				PlainTextView(text: _textValue)
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}

@available(macOS 10.15, *)
struct ScrollingTextViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			Group {
				PlainTextView(text: _textValue, wrapsLines: false)
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}


private let __dummyText = """
In my younger and more vulnerable years my father gave me some advice that I’ve been turning over in my mind ever since.

“Whenever you feel like criticizing anyone,” he told me, “just remember that all the people in this world haven’t had the advantages that you’ve had.”

He didn’t say any more, but we’ve always been unusually communicative in a reserved way, and I understood that he meant a great deal more than that. In consequence, I’m inclined to reserve all judgements, a habit that has opened up many curious natures to me and also made me the victim of not a few veteran bores. The abnormal mind is quick to detect and attach itself to this quality when it appears in a normal person, and so it came about that in college I was unjustly accused of being a politician, because I was privy to the secret griefs of wild, unknown men. Most of the confidences were unsought—frequently I have feigned sleep, preoccupation, or a hostile levity when I realized by some unmistakable sign that an intimate revelation was quivering on the horizon; for the intimate revelations of young men, or at least the terms in which they express them, are usually plagiaristic and marred by obvious suppressions. Reserving judgements is a matter of infinite hope. I am still a little afraid of missing something if I forget that, as my father snobbishly suggested, and I snobbishly repeat, a sense of the fundamental decencies is parcelled out unequally at birth.

And, after boasting this way of my tolerance, I come to the admission that it has a limit. Conduct may be founded on the hard rock or the wet marshes, but after a certain point I don’t care what it’s founded on. When I came back from the East last autumn I felt that I wanted the world to be in uniform and at a sort of moral attention forever; I wanted no more riotous excursions with privileged glimpses into the human heart. Only Gatsby, the man who gives his name to this book, was exempt from my reaction—Gatsby, who represented everything for which I have an unaffected scorn. If personality is an unbroken series of successful gestures, then there was something gorgeous about him, some heightened sensitivity to the promises of life, as if he were related to one of those intricate machines that register earthquakes ten thousand miles away. This responsiveness had nothing to do with that flabby impressionability which is dignified under the name of the “creative temperament”—it was an extraordinary gift for hope, a romantic readiness such as I have never found in any other person and which it is not likely I shall ever find again. No—Gatsby turned out all right at the end; it is what preyed on Gatsby, what foul dust floated in the wake of his dreams that temporarily closed out my interest in the abortive sorrows and short-winded elations of men.
"""

#endif
