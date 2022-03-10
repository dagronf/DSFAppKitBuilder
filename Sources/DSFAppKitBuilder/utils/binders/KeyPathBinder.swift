//
//  KeyPathBinder.swift
//
//  Created by Darren Ford on 14/9/21
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

/// A read-only key-path binder
public class KeyPathBinder<TYPE: Any>: KeyPathBinderCore<TYPE> {
	/// Create a readonly keypath value binder
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
	override public init(
		_ value: TYPE,
		_ changeCallback: ((TYPE) -> Void)? = nil
	) {
		super.init(value, changeCallback)
	}

	/// Create and listen to changes in an object and keypath. Read only.
	///
	/// - Parameters:
	///   - value: The initial value for the binding
	///   - observable: The object to observe
	///   - keyPath: The keypath to observe within the object
	///   - changeCallback: (optional) A callback block to call when the value changes
	public init<TARGET>(
		_ value: TYPE,
		observable: NSObject,
		keyPath: KeyPath<TARGET, TYPE>,
		_ changeCallback: ((TYPE) -> Void)? = nil
	) {
		super.init(value, changeCallback)

		self.wrappedValue = value

		// If a callback is requested, then set ourselves up as a binding too
		if let callback = changeCallback {
			self.register(self, callback)
		}

		self.listen(observable: observable, keyPath: keyPath)
	}

	/// Listen to changes in an object and keypath. Read only.
	///
	/// - Parameters:
	///   - observable: The object to observe
	///   - keyPath: The keypath to observe within the object
	public func listen<TARGET>(observable: NSObject, keyPath: KeyPath<TARGET, TYPE>) {
		// Unbind if we are already bound.
		self.unbind()

		let stringKeyPath = NSExpression(forKeyPath: keyPath).keyPath
		guard !stringKeyPath.isEmpty else {
			fatalError("Unable to convert keyPath \(keyPath)")
		}

		self.bindValueObserver = observable
		self.bindStringKeyPath = stringKeyPath
		observable.addObserver(self, forKeyPath: stringKeyPath, options: [.new], context: nil)

		// Grab the initial state for the binder object from the observed object
		if let newVal = observable.value(forKeyPath: stringKeyPath) as? TYPE {
			self.isUpdatingFromBinding = true
			self.wrappedValue = newVal
			self.isUpdatingFromBinding = false
		}
	}
}

/// A ValueBinder that can sync with a observable keypath
public class WritableKeyPathBinder<TYPE: Any>: KeyPathBinderCore<TYPE> {
	/// Create a read/write keypath value binder
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
	override public init(
		_ value: TYPE,
		_ changeCallback: ((TYPE) -> Void)? = nil
	) {
		super.init(value, changeCallback)
	}

	/// Create and sync to changes in an object and keypath (read/write).
	///
	/// - Parameters:
	///   - value: The initial value for the binding
	///   - observable: The object to observe
	///   - keyPath: The keypath to observe within the object
	///   - changeCallback: (optional) A callback block to call when the value changes
	public init<TARGET>(
		_ value: TYPE,
		observable: NSObject,
		keyPath: ReferenceWritableKeyPath<TARGET, TYPE>,
		_ changeCallback: ((TYPE) -> Void)? = nil
	) {
		super.init(value, changeCallback)

		self.wrappedValue = value

		// If a callback is requested, then set ourselves up as a binding too
		if let callback = changeCallback {
			self.register(self, callback)
		}

		self.bind(observable: observable, keyPath: keyPath)
	}

	/// Two-way bind an object and keypath
	/// - Parameters:
	///   - observable: The object to observe
	///   - keyPath: The keypath to observe within the object
	public func bind<TARGET>(observable: NSObject, keyPath: ReferenceWritableKeyPath<TARGET, TYPE>) {
		// Unbind if we are already bound.
		self.unbind()

		let stringKeyPath = NSExpression(forKeyPath: keyPath).keyPath
		guard !stringKeyPath.isEmpty else {
			fatalError("Unable to convert keyPath \(keyPath)")
		}
		self.bindValueObserver = observable
		self.bindStringKeyPath = stringKeyPath
		observable.addObserver(self, forKeyPath: stringKeyPath, options: [.new], context: nil)

		// Set the initial value for the binding from our stored value
		observable.setValue(self.wrappedValue, forKeyPath: stringKeyPath)
	}
}

/////

public class KeyPathBinderCore<TYPE: Any>: ValueBinder<TYPE> {
	/// Disconnect the keypath binding
	public func unbind() {
		if let observer = self.bindValueObserver,
		   let keyPath = self.bindStringKeyPath
		{
			observer.removeObserver(self, forKeyPath: keyPath)
			self.bindValueObserver = nil
			self.bindStringKeyPath = nil
		}
	}

	deinit {
		self.unbind()
	}

	/// Called when the keypath is updated
	override public func observeValue(
		forKeyPath keyPath: String?,
		of object: Any?,
		change: [NSKeyValueChangeKey: Any]?,
		context: UnsafeMutableRawPointer?
	) {
		if let kp = self.bindStringKeyPath,
		   kp == keyPath,
		   let newVal = change?[.newKey] as? TYPE
		{
			self.isUpdatingFromBinding = true
			self.wrappedValue = newVal
			self.isUpdatingFromBinding = false
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}

	/// Called when the ValueBinder value changed. Push our wrapped value back into the object/keypath
	override public func valueDidChange() {
		super.valueDidChange()

		if !self.isUpdatingFromBinding {
			self.isUpdatingFromBinding = true
			if let obs = self.bindValueObserver,
			   let kp = self.bindStringKeyPath
			{
				obs.setValue(self.wrappedValue, forKeyPath: kp)
			}
			self.isUpdatingFromBinding = false
		}
	}

	// If value binding to a key path
	fileprivate(set) weak var bindValueObserver: NSObject?
	fileprivate var bindStringKeyPath: String?
	fileprivate var isUpdatingFromBinding = false
}
