//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSColorWell

/// An color view
public class ColorWell: Control {

	public init(
		tag: Int? = nil,
		showsAlpha: Bool = false,
		isBordered: Bool = true,
		color: NSColor? = nil)
	{
		super.init(tag: tag)

		self.colorWell.showsAlpha = showsAlpha

		self.colorWell.isBordered = isBordered
		if let c = color { self.colorWell.color = c }
	}

	/// Set a callback block for when the color changes
	public func onChange(_ block: @escaping (NSColor) -> Void) -> Self {
		self.actionCallback = block
		self.colorWell.target = self
		self.colorWell.action = #selector(colorChanged(_:))
		return self
	}

	@objc private func colorChanged(_ sender: Any) {
		self.actionCallback?(self.colorWell.color)
	}

	/// Bind the image to a keypath
	public func bindColor<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSColor>) -> Self {
		self.colorBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.colorWell.color = newValue
		})
		return self
	}

	// Privates
	private let colorWell = AlphaCompatibleColorWell()
	public override var nsView: NSView { return self.colorWell }

	private lazy var colorBinder = Bindable<NSColor>()
	private var actionCallback: ((NSColor) -> Void)? = nil

}

class AlphaCompatibleColorWell: NSColorWell {
	var showsAlpha: Bool = false
	override func activate(_ exclusive: Bool) {
		NSColorPanel.shared.showsAlpha = self.showsAlpha
		super.activate(exclusive)
	}
}
