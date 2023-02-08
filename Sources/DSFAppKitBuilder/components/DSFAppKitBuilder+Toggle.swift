//
//  DSFAppKitBuilder+Toggle.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
import DSFToggleButton
import DSFValueBinders
import DSFAppearanceManager

/// A DSFToggleButton wrapper.
///
/// ```swift
/// Toggle(state: toggleState2, showLabels: true) { newState in
///    // Do something with 'newState'
/// }
/// .size(width: 200, height: 100)
/// ```
///
public class Toggle: Control {

	public enum State {
		case off
		case on
	}

	class ControlSize {
		static let mini    = CGSize(width: 28, height: 16)
		static let small   = CGSize(width: 36, height: 21)
		static let regular = CGSize(width: 42, height: 25)
		static let large   = CGSize(width: 50, height: 30)
	}

	public typealias ToggleAction = (State) -> Void

	/// Create a switch
	/// - Parameters
	///   - state: The initial state for the control
	///   - color: The color for the control, or the system accent color if nil
	///   - showLabels: Show the toggle button labels
	///   - onChange: The block to call when the state of the button changes
	public init(
		state: State = .off,
		color: NSColor? = nil,
		showLabels: Bool = false,
		_ onChange: ToggleAction? = nil
	) {
		super.init()

		// Set a default size
		self.size(width: 42, height: 25)

		self.toggleButton.color = color ?? DSFAppearanceCache.shared.accentColor

		if let onChange = onChange {
			self.action = onChange
		}

		self.toggleButton.state = (state == .on) ? .on : .off

		self.toggleButton.showLabels = showLabels
		self.toggleButton.target = self
		self.toggleButton.action = #selector(self.performAction(_:))

		self.customColor = color
	}

	/// Create a toggle button
	/// - Parameters
	///   - state: The binding for the on/off state of the control
	///   - color: The color for the control, or the system accent color if nil
	///   - showLabels: Show the toggle button labels
	public init(
		state: ValueBinder<State>,
		color: NSColor? = nil,
		showLabels: Bool = false
	) {
		super.init()

		// Set a default size
		self.size(width: 42, height: 25)

		self.stateBinder = state

		state.register(self) { [weak self] newState in
			self?.toggleButton.state = (newState == .on) ? .on : .off
		}

		self.toggleButton.color = color ?? DSFAppearanceCache.shared.accentColor

		self.toggleButton.showLabels = showLabels
		self.toggleButton.target = self
		self.toggleButton.action = #selector(self.performAction(_:))

		self.customColor = color
	}

	deinit {
		self.action = nil
		self.customColor = nil
		self.onOffBinder?.deregister(self)
		self.onOffBinder = nil
		self.stateBinder?.deregister(self)
		self.stateBinder = nil
		self.colorBinder?.deregister(self)
		self.colorBinder = nil
	}

	private let toggleButton = DSFToggleButton()
	public override func view() -> NSView { return self.toggleButton }

	private var action: ToggleAction?
	private var stateBinder: ValueBinder<State>?
	private var onOffBinder: ValueBinder<Bool>?
	private var colorBinder: ValueBinder<NSColor>?
	private var customColor: NSColor?

	/// Called when the user changes an aspect of the system's theme
	public override func onThemeChange() {
		super.onThemeChange()
		if self.colorBinder == nil, self.customColor == nil {
			// If there's no forced color specified, update the control to use a new accent color
			self.toggleButton.color = DSFAppearanceCache.shared.accentColor
		}
	}

	// Called when the button state is changed
	@objc private func performAction(_ item: NSButton) {
		let newState = (item.state != .off) ? State.on : State.off

		// Call the action callback if it is set
		self.action?(newState)

		// Tell the binders to update
		self.stateBinder?.wrappedValue = newState
		self.onOffBinder?.wrappedValue = (newState == .on)
	}

	@objc public override func onControlSizeChange(_ controlSize: NSControl.ControlSize) {
		let sz: CGSize
		switch controlSize {
		case .regular: sz = ControlSize.regular
		case .small: sz = ControlSize.small
		case .mini: sz = ControlSize.mini
		case .large: sz = ControlSize.large
		@unknown default:
			fatalError()
		}
		self.size(width: Double(sz.width), height: Double(sz.height))
	}
}

// MARK: - Actions

public extension Toggle {
	/// Set a block to be called when the button state changes
	///
	/// Passes the new button state to the callback block
	func onChange(_ onChange: @escaping ToggleAction) -> Self {
		self.action = onChange
		return self
	}
}

// MARK: - Bindings

public extension Toggle {
	/// Bind the color of the toggle button to a color ValueBinder
	func bindColor(_ color: ValueBinder<NSColor>) -> Self {
		self.colorBinder = color
		color.register(self) { [weak self] newColor in
			self?.toggleButton.color = newColor
		}
		return self
	}

	/// Bind the on-off state for the toggle
	func bindOnOff(_ state: ValueBinder<Bool>) -> Self {
		self.onOffBinder = state
		state.register(self) { [weak self] newState in
			self?.toggleButton.state = newState ? .on : .off
		}
		return self
	}
}

// MARK: - ValueBinder transforms

public extension ValueBinder where ValueType == Toggle.State {
	/// A ValueBinder transform for converting Toggle.State types to bool (true/false)
	///
	/// For example, you might bind the enabled state of another item
	///
	/// ```swift
	/// let vState = ValueBinder<Toggle.State>(.on)
	/// Toggle(state: vState)
	/// Button("Something") { ... }
	///    .bindIsEnabled(vState.boolValue())
	/// ```
	func boolValue() -> ValueBinder<Bool> {
		self.transform { $0 == .on }
	}
}

// MARK: - SwiftUI preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

private let __v1 = ValueBinder<Toggle.State>(.off)
private let __v2 = ValueBinder<Toggle.State>(.on)

@available(macOS 10.15, *)
struct TogglePreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack {
				Label("Default sizing")
				HStack {
					Toggle(state: .off)
					Toggle(state: .off)
						.isEnabled(false)
					Toggle(state: .on)
					Toggle(state: .on)
						.isEnabled(false)
				}
				Label("Control sizing")
				HStack {
					VStack {
						Toggle(state: .on).controlSize(.mini)
						Label(".mini")
					}
					VStack {
						Toggle(state: .on).controlSize(.small)
						Label(".small")
					}
					VStack {
						Toggle(state: .on).controlSize(.regular)
						Label(".regular")
					}
//					VStack {
//						Toggle(state: .on).controlSize(.large)
//						Label(".large")
//					}
				}
				HDivider()
				Label("100x50, not labelled")
				HStack {
					Toggle(state: .off)
						.size(width: 100, height: 50)
					Toggle(state: .off)
						.isEnabled(false)
						.size(width: 100, height: 50)
					Toggle(state: .on)
						.size(width: 100, height: 50)
					Toggle(state: .on)
						.isEnabled(false)
						.size(width: 100, height: 50)
				}
				HDivider()
				Label("100x50, labelled")
				HStack {
					Toggle(state: .off, showLabels: true)
						.size(width: 100, height: 50)
					Toggle(state: .off, showLabels: true)
						.isEnabled(false)
						.size(width: 100, height: 50)
					Toggle(state: .on, showLabels: true)
						.isEnabled(true)
						.size(width: 100, height: 50)
					Toggle(state: .on, showLabels: true)
						.isEnabled(false)
						.size(width: 100, height: 50)
				}
				HDivider()
				Label("30x30, not labelled")
				HStack {
					Toggle(state: .off, color: NSColor.systemRed)
						.size(width: 30, height: 30)
					Toggle(state: .on, color: NSColor.systemRed)
						.size(width: 30, height: 30)
					Toggle(state: .on, color: NSColor.systemGreen)
						.size(width: 30, height: 30)
					Toggle(state: .on, color: NSColor.systemBlue)
						.size(width: 30, height: 30)
				}
				HDivider()
				Label("150x100")
				HStack {
					Toggle(state: .on, color: NSColor.systemRed)
						.size(width: 150, height: 100)
					Toggle(state: .on, color: NSColor.systemGreen)
						.size(width: 150, height: 100)
					Toggle(state: .on, color: NSColor.systemBlue)
						.size(width: 150, height: 100)
				}
				HDivider()
				Label("400x300")
				HStack {
					Toggle(state: .off, color: NSColor.systemYellow, showLabels: true)
						.size(width: 300, height: 200)
					Toggle(state: .on, color: NSColor.systemYellow, showLabels: true)
						.size(width: 300, height: 200)
				}
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
