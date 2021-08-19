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
///    .bindState(self.switchState)
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
	public override func view() -> NSView { return self.switchView }

	private var actionCallback: ((NSButton.StateValue) -> Void)?
	private var stateBinder: ValueBinder<NSControl.StateValue>?
	private var onOffBinder: ValueBinder<Bool>?
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
		self.stateBinder?.wrappedValue = self.switchView.state
		self.onOffBinder?.wrappedValue = (self.switchView.state == .off ? false : true)
	}
}

// MARK: - Bindings

@available(macOS 10.15, *)
public extension Switch {

	/// Bind the on/off switch state.
	func bindOnOffState(_ stateBinding: ValueBinder<Bool>) -> Self {
		self.onOffBinder = stateBinding
		stateBinding.register(self) { [weak self] newValue in
			let newState: NSControl.StateValue = (newValue == false) ? .off : .on
			self?.switchView.state = newState
			self?.stateBinder?.wrappedValue = newState
		}

		return self
	}

	/// Bind the switch state
	func bindState(_ stateBinding: ValueBinder<NSControl.StateValue>) -> Self {
		self.stateBinder = stateBinding
		stateBinding.register(self) { [weak self] newValue in
			self?.switchView.state = newValue
			self?.onOffBinder?.wrappedValue = newValue == .off ? false : true
		}
		return self
	}
}
