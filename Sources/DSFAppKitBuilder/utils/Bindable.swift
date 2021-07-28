//
//  Bindable.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import Foundation

///
internal class Bindable<VALUETYPE>: NSObject {

	typealias BindableCallback = (VALUETYPE) -> Void

	private(set) var bindValueKeyPath: String?
	private(set) weak var bindValueObserver: AnyObject?

	private var valueChangeCallback: BindableCallback?

	public var isActive: Bool {
		return valueChangeCallback != nil
	}

	deinit {
		bindValueKeyPath = nil
		bindValueObserver = nil
		valueChangeCallback = nil
	}

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
		if let kp = bindValueKeyPath {
			bindValueObserver?.setValue(value, forKeyPath: kp)
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
