//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

@available(macOS 10.15, *)
public class Switch: Control {
	let switchView = NSSwitch()
	public override var nsView: NSView { return self.switchView }

	public init(
		tag: Int? = nil,
		state: NSControl.StateValue = .off
	) {
		super.init(tag: tag)
		self.switchView.state = state
	}

	private var action: ((NSSwitch) -> Void)?
	public func action(_ action: @escaping ((NSSwitch) -> Void)) -> Self {
		self.setAction(action)
		return self
	}

	private func setAction(_ action: @escaping ((NSSwitch) -> Void)) {
		self.action = action
		self.switchView.target = self
		self.switchView.action = #selector(self.performAction(_:))
	}

	@objc internal func performAction(_ item: NSSwitch) {
		self.action?(item)
	}

	private lazy var stateBinder = Bindable<NSControl.StateValue>()
	public func bindState<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSControl.StateValue>) -> Self {

		self.action = nil
		self.switchView.target = self
		self.switchView.action = #selector(switchDidChange(_:))

		self.stateBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.switchView.state = newValue
		})
		self.stateBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	@objc private func switchDidChange(_ sender: Any) {
		stateBinder.setValue(self.switchView.doubleValue)
	}
}
