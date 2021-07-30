//
//  DSFAppKitBuilder+Switch.swift
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

import AppKit

@available(macOS 10.15, *)
public class Switch: Control {
	public init(
		tag: Int? = nil,
		state: NSControl.StateValue = .off
	) {
		super.init(tag: tag)
		self.switchView.state = state

		self.switchView.target = self
		self.switchView.action = #selector(self.switchDidChange(_:))
	}

	// Private

	let switchView = NSSwitch()
	public override var nsView: NSView { return self.switchView }

	private var action: ((NSButton.StateValue) -> Void)?
	private lazy var stateBinder = Bindable<NSControl.StateValue>()

}

// MARK: - Actions

@available(macOS 10.15, *)
public extension Switch {
	func action(_ action: @escaping ((NSButton.StateValue) -> Void)) -> Self {
		self.setAction(action)
		return self
	}

	private func setAction(_ action: @escaping ((NSButton.StateValue) -> Void)) {
		self.action = action
	}

	@objc private func switchDidChange(_ sender: NSSwitch) {
		self.action?(sender.state)
		if stateBinder.isActive {
			stateBinder.setValue(self.switchView.state)
		}
	}
}

// MARK: - Bindings

@available(macOS 10.15, *)
public extension Switch {

	/// Bind the switch state to a keypath
	func bindState<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSControl.StateValue>) -> Self {
		self.action = nil
		self.switchView.target = self
		self.switchView.action = #selector(switchDidChange(_:))

		self.stateBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.switchView.state = newValue
		})
		self.stateBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}
}
