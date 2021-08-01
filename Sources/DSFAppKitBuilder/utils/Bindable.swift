//
//  Bindable.swift
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

import Foundation

// Binding object
internal class Bindable<VALUETYPE>: NSObject {

	typealias BindableCallback = (VALUETYPE) -> Void

	private(set) var bindValueKeyPath: String?
	private(set) weak var bindValueObserver: AnyObject?

	private var valueChangeCallback: BindableCallback?

	// Is this bindable currently bound to a keypath?
	var isActive: Bool {
		return valueChangeCallback != nil
	}

	deinit {
		self.bindValueKeyPath = nil
		self.bindValueObserver = nil
		self.valueChangeCallback = nil
	}

	// Bind an object-keypath to this value
	func bind<TYPE, VALUETYPE>(
		_ object: AnyObject,
		keyPath: ReferenceWritableKeyPath<TYPE, VALUETYPE>,
		onChange: @escaping BindableCallback)
	{
		self.valueChangeCallback = onChange
		let stringKeyPath = NSExpression(forKeyPath: keyPath).keyPath
		assert(stringKeyPath.isEmpty == false)
		bindValueKeyPath = stringKeyPath
		self.bindValueObserver = object
		object.addObserver(self, forKeyPath: stringKeyPath, options: [.new], context: nil)

		// Initialize the binder with the current value of the keypath
		self.setValue(object.value(forKeyPath: stringKeyPath))
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if let observerKeyPath = self.bindValueKeyPath, observerKeyPath == keyPath,
			let newVal = change?[.newKey] as? VALUETYPE {
			self.valueChangeCallback?(newVal)
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}

	func setValue<VALUETYPE>(_ value: VALUETYPE) {
		guard self.isActive else {
			// Do nothing if we're currently not bound to a keypath
			return
		}
		if let kp = bindValueKeyPath {
			self.bindValueObserver?.setValue(value, forKeyPath: kp)
		}
	}

	func unbind() {
		if let observer = self.bindValueObserver,
			let keyPath = self.bindValueKeyPath {
			observer.removeObserver(self, forKeyPath: keyPath)
		}
		self.bindValueKeyPath = nil
		self.bindValueObserver = nil
	}
}
