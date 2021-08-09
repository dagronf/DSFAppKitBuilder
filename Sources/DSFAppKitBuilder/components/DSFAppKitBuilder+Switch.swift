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

/// A switch element
///
/// Usage:
///
/// ```swift
/// Switch(state: .on)
///    .bindState(self, keyPath: \MyController.switchState)
/// ```
///
@available(macOS 10.15, *)
public class Switch: Control {

	/// Create a switch
	/// - Parameter state: the initial state for the control
	public init(
		state: NSControl.StateValue = .off
	) {
		super.init()
		self.switchView.state = state

		self.switchView.target = self
		self.switchView.action = #selector(self.switchDidChange(_:))
	}

	// Private

	let switchView = NSSwitch()
	override public var nsView: NSView { return self.switchView }

	private var actionCallback: ((NSButton.StateValue) -> Void)?
	private lazy var stateBinder = Bindable<NSControl.StateValue>()
	private lazy var onOffBinder = Bindable<Bool>()
}

// MARK: - Actions

@available(macOS 10.15, *)
public extension Switch {

	/// Set a block to be called when the button is activated
	func onAction(_ action: @escaping ((NSButton.StateValue) -> Void)) -> Self {
		self.actionCallback = action
		return self
	}

	@objc private func switchDidChange(_ sender: NSSwitch) {
		self.actionCallback?(sender.state)
		self.stateBinder.setValue(self.switchView.state)
		self.onOffBinder.setValue(self.switchView.state == .off ? false : true)
	}
}

// MARK: - Bindings

@available(macOS 10.15, *)
public extension Switch {

	/// Bind the on/off switch state to a keypath.
	func bindOnOffState<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Bool>) -> Self {
		self.onOffBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.switchView.state = (newValue == false) ? .off : .on
		})
		return self
	}

	/// Bind the switch state to a keypath
	func bindState<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSControl.StateValue>) -> Self {
		self.stateBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.switchView.state = newValue
		})
		return self
	}
}
