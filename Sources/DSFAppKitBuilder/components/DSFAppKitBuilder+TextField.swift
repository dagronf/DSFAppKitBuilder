//
//  DSFAppKitBuilder+TextField.swift
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

import AppKit.NSTextField

/// An editable text control
public class TextField: Label, NSTextFieldDelegate {
	var didBeginEditing: ((NSTextField) -> Void)?
	var didEdit: ((NSTextField) -> Void)?
	var didEndEditing: ((NSTextField) -> Void)?

	public init(tag: Int? = nil,
					_ label: String? = nil,
					_ placeholderText: String? = nil)
	{
		super.init(tag: tag, label)
		self.label.isEditable = true
		self.label.isBezeled = true
		if let p = placeholderText {
			self.label.placeholderString = p
		}
		self.label.delegate = self
	}

	public func placeholderText(_ label: String) -> Self {
		self.label.placeholderString = label
		return self
	}

	public func isContinuous(_ b: Bool) -> Self {
		self.label.isContinuous = b
		return self
	}

	// MARK: - Editing callbacks

	public func didStartEditing(_ block: @escaping (NSTextField) -> Void) -> Self {
		self.didBeginEditing = block
		return self
	}

	public func didEdit(_ block: @escaping (NSTextField) -> Void) -> Self {
		self.didEdit = block
		return self
	}

	public func didEndEditing(_ block: @escaping (NSTextField) -> Void) -> Self {
		self.didEndEditing = block
		return self
	}

	public func controlTextDidBeginEditing(_: Notification) {
		self.didBeginEditing?(self.label)
	}

	public func controlTextDidChange(_: Notification) {
		self.didEdit?(self.label)
	}

	public func controlTextDidEndEditing(_: Notification) {
		self.didEndEditing?(self.label)
	}
}
