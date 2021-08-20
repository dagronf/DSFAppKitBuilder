//
//  Bind.swift
//
//  Created by Darren Ford on 10/8/21
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

import Foundation

// MARK: - ValueBinder

/// A wrapped value binder for sharing dynamic values between elements
public class ValueBinder<TYPE: Any> {
	/// The wrapped value to be bound against
	public var wrappedValue: TYPE {
		didSet {
			self.valueDidChange()
		}
	}

	/// Create a bound value
	///
	/// - Parameters:
	///   - value: The initial value for the binding
	///   - changeCallback: (optional) A callback block to call when the value changes
	///
	/// Example usage:
	/// ```swift
	/// let firstNameBinder = ValueBinder("") { newValue in
	///    Swift.print("firstName changed to '\(newValue)'")
	/// }
	/// let ageBinder = ValueBinder(21) { newValue in
	///    Swift.print("age changed to '\(newValue)'")
	/// }
	/// ```
	public init(_ value: TYPE, _ changeCallback: ((TYPE) -> Void)? = nil) {
		self.wrappedValue = value

		// If a callback is requested, then set ourselves up as a binding too
		if let callback = changeCallback {
			self.register(self, callback)
		}
	}

	deinit {
#if DEBUG
		Logger.Debug("ValueBinder<\(type(of: self.wrappedValue))> [\(type(of: self))] deinit")
#endif
		self.deregisterAll()
	}

	// Private
	private var bindings = [Binding]()
}

// MARK: - Register/Deregister

public extension ValueBinder {
	/// Register an object to be notified when the value changes
	/// - Parameters:
	///   - object: The registering object. Held weakly to detect when the registering object is deallocated and we should no longer call the change block
	///   - changeBlock: The block to call when the value in the ValueBinder instance changes
	func register(_ object: AnyObject, _ changeBlock: @escaping (TYPE) -> Void) {
#if DEBUG
		Logger.Debug("ValueBinder<\(type(of: self.wrappedValue))> [\(type(of: object))] register...")
#endif

		// First a little housekeeping...
		self.cleanupInactiveBindings()

		// Add the binding
		self.bindings.append(Binding(object, changeBlock))

		// Call with the initial value to initialize the binding object's state
		changeBlock(self.wrappedValue)
	}

	// Deregister a binding
	// - Parameter object: The object to deregister
	func deregister(_ object: AnyObject) {
#if DEBUG
		Logger.Debug("ValueBinder<\(type(of: self.wrappedValue))> [\(type(of: object))] ...deregistered!")
#endif
		self.bindings = self.bindings.filter { $0.isAlive && $0.object !== object }
	}

	// Deregister all bindings
	func deregisterAll() {
		self.bindings.forEach { $0.deregister() }
		self.bindings = []
	}
}

// MARK: - Value handling

private extension ValueBinder {

	// Called when the wrappedValue is updated
	func valueDidChange() {
		let value = self.wrappedValue
		self.bindings.forEach { binding in
			binding.didChange(value)
		}
	}

	// Remove any inactive bindings
	func cleanupInactiveBindings() {
		self.bindings = self.bindings.filter { $0.isAlive }
	}
}

private extension ValueBinder {
	// A binding object that stores an object and a callback for a valuebinder
	class Binding {
		// Is the registering object still alive?
		@inlinable var isAlive: Bool { return object != nil }

		// A weakly held registration object to keep track of the lifetimes of the change block
		weak var object: AnyObject?

		// Callback for when the value changes
		private var changeBlock: ((TYPE) -> Void)?

		// Create a binding
		init(_ object: AnyObject, _ changeBlock: @escaping (TYPE) -> Void) {
			self.object = object
			self.changeBlock = changeBlock
		}

		// Deregister this binder to stop it receiving change notifications
		fileprivate func deregister() {
			self.object = nil
			self.changeBlock = nil
		}

		// Called when the wrapped value changes. Propagate the new value through the changeblock
		func didChange(_ value: TYPE) {
			if let _ = object, let callback = changeBlock {
				callback(value)
			}
			else {
				self.deregister()
			}
		}
	}
}
