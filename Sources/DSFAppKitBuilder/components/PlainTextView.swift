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

public class PlainTextView: Element {
	/// Create a plain text (ie. no text formatting) scrollable editor view
	/// - Parameters:
	///   - text: The text binder for the content of the view
	///   - borderType: The type of border to use
	///   - wrapsLines: If true, text is word-wrapped at the edge of the text view
	///   - isEditable: Is the text editable?
	///   - isSelectable: Is the text selectable?
	public init(
		text: ValueBinder<String>,
		borderType: NSBorderType? = nil,
		wrapsLines: Bool = true,
		isEditable: Bool? = nil,
		isSelectable: Bool? = nil
	) {
		self.textBinder = text

		super.init()

		if let borderType = borderType { contentView.scrollView.borderType = borderType }
		if let isEditable = isEditable { contentView.textView.isEditable = isEditable }
		if let isSelectable = isSelectable { contentView.textView.isSelectable = isSelectable }

		if #available(macOS 10.14, *) {
			contentView.textView.usesAdaptiveColorMappingForDarkAppearance = true
		} else {
			 // Fallback on earlier versions - do nothing
		}

		self.textBinder.register(self) { [weak self] newText in
			guard let `self` = self else { return }
			if !self.isUpdating {
				self.isUpdating = true
				self.contentView.textView.string = newText
				self.isUpdating = false
			}
		}

		self.contentView.textView.delegate = self

		self.configure(wrapsLines: wrapsLines)
	}

	private func configure(wrapsLines: Bool) {
		self.contentView.wrapText(wrapsLines)
	}

	deinit {
		self.wrapsBinder?.deregister(self)
		self.wrapsBinder = nil
	}

	private let contentView = ScrollableTextView()
	private let textBinder: ValueBinder<String>
	private var wrapsBinder: ValueBinder<Bool>?
	private var editableBinder: ValueBinder<Bool>?
	private var selectableBinder: ValueBinder<Bool>?
	private var selectionRangeBinder: ValueBinder<NSRange>?
	private var isUpdating = false

	override public func view() -> NSView { self.contentView }
}

extension PlainTextView: NSTextViewDelegate {
	public func textViewDidChangeSelection(_ notification: Notification) {
		if !self.isUpdating {
			self.isUpdating = true
			self.selectionRangeBinder?.wrappedValue = self.contentView.textView.selectedRange()
			self.isUpdating = false
		}
	}

	public func textDidChange(_ notification: Notification) {
		if !self.isUpdating {
			self.isUpdating = true
			self.textBinder.wrappedValue = self.contentView.textView.string
			self.isUpdating = false
		}
	}
}

// MARK: - Modifiers

public extension PlainTextView {
	/// Is the text view editable
	@discardableResult func isEditable(_ editable: Bool) -> Self {
		self.contentView.textView.isEditable = editable
		return self
	}

	/// Is the text view selectable?
	@discardableResult func isSelectable(_ selectable: Bool) -> Self {
		self.contentView.textView.isSelectable = selectable
		return self
	}

	/// Set the font to use for display
	@discardableResult func font(_ font: AKBFont) -> Self {
		self.contentView.textView.font = font.font
		return self
	}

	/// Set the font to use for display
	@discardableResult func font(_ font: NSFont) -> Self {
		self.contentView.textView.font = font
		return self
	}

	/// A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	@discardableResult func autohidesScrollers(_ hides: Bool) -> Self {
		self.contentView.scrollView.autohidesScrollers = hides
		return self
	}
}

// MARK: - Bindings

public extension PlainTextView {
	/// Create a binding to toggle wrapping on the text view
	@discardableResult func bindWrapsText(_ binder: ValueBinder<Bool>) -> Self {
		self.wrapsBinder = binder
		binder.register(self) { [weak self] newValue in
			self?.configure(wrapsLines: newValue)
		}
		return self
	}

	/// Create a binding to toggle wrapping on the text view
	@discardableResult func bindIsEditable(_ binder: ValueBinder<Bool>) -> Self {
		self.editableBinder = binder
		binder.register(self) { [weak self] newValue in
			self?.contentView.textView.isEditable = newValue
		}
		return self
	}

	/// Create a binding to toggle wrapping on the text view
	@discardableResult func bindIsSelectable(_ binder: ValueBinder<Bool>) -> Self {
		self.selectableBinder = binder
		binder.register(self) { [weak self] newValue in
			self?.contentView.textView.isSelectable = newValue
		}
		return self
	}

	/// Create a binding for single range selection
	@discardableResult func bindSelectedRange(_ binder: ValueBinder<NSRange>) -> Self {
		self.selectionRangeBinder = binder
		binder.register(self) { [weak self] newValue in
			guard let `self` = self else { return }
			if !self.isUpdating {
				self.isUpdating = true
				self.contentView.textView.selectedRanges = [NSValue(range: newValue)]
				self.isUpdating = false
			}
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
