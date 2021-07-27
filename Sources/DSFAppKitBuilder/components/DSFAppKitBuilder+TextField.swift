//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSTextField

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
