//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSButton

public class Button: Control {

	public init(
		tag: Int? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle _: NSButton.BezelStyle = .rounded,
		_: String
	) {
		super.init(tag: tag)
		self.button.bezelStyle = .rounded
		self.button.setButtonType(type)
	}

	public init(
		tag: Int? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle _: NSButton.BezelStyle = .rounded,
		_: String,
		_ action: @escaping ((NSButton) -> Void)
	) {
		super.init(tag: tag)
		self.button.bezelStyle = .rounded
		self.button.setButtonType(type)

		self.setAction(action)
	}

	public init(
		tag: Int? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle _: NSButton.BezelStyle = .rounded,
		_: String,
		_ target: AnyObject, action: Selector
	) {
		super.init(tag: tag)
		self.button.bezelStyle = .rounded
		self.button.setButtonType(type)
		self.button.isEnabled = true

		self.setAction(target, action: action)
	}

	// MARK: Title

	/// Set the button's title
	public func title(_ title: String) -> Self {
		self.button.stringValue = title
		return self
	}

	/// Bind the title to a keypath
	public func bindTitle<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.titleBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.button.title = newValue
		})
		return self
	}

	// MARK: Alternate Title

	/// The title that the button displays when the button is in an on state.
	public func alternateTitle(_ title: String) -> Self {
		self.button.alternateTitle = title
		return self
	}

	/// Bind the alternatetitle to a keypath
	public func bindAlternateTitle<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.alternateTitleBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.button.alternateTitle = newValue
		})
		return self
	}

	// MARK: Image

	/// Set the image that appears on the button when it’s in an off state
	public func image(
		_ image: NSImage,
		imagePosition: NSControl.ImagePosition = .imageLeading,
		imageScaling: NSImageScaling? = nil,
		imageHugsTitle: Bool? = nil) -> Self
	{
		self.button.image = image
		self.button.imagePosition = imagePosition
		if let i = imageHugsTitle { self.button.imageHugsTitle = i }
		if let i = imageScaling { self.button.imageScaling = i }
		return self
	}

	/// Set the image that appears on the button when it’s in an on state
	public func alternateImage(_ image: NSImage) -> Self{
		self.button.alternateImage = image
		return self
	}

	// A Boolean value that determines whether the button has a border.
	public func isBordered(_ isBordered: Bool) -> Self {
		self.button.isBordered = isBordered
		return self
	}

	// MARK: Actions

	public func action(_ target: AnyObject, action: Selector) -> Self {
		self.setAction(target, action: action)
		return self
	}

	public func action(_ action: @escaping ((NSButton) -> Void)) -> Self {
		self.setAction(action)
		return self
	}

	private func setAction(_: AnyObject, action: Selector) {
		self.action = nil
		self.button.target = self
		self.button.action = action
	}

	private func setAction(_ action: @escaping ((NSButton) -> Void)) {
		self.action = action
		self.button.target = self
		self.button.action = #selector(self.performAction(_:))
	}

	@objc internal func performAction(_ item: NSButton) {
		self.action?(item)
	}

	// Privates

	private let button = NSButton()
	public override var nsView: NSView { return self.button }
	private var action: ((NSButton) -> Void)?

	private lazy var titleBinder = Bindable<String>()
	private lazy var alternateTitleBinder = Bindable<String>()
}
