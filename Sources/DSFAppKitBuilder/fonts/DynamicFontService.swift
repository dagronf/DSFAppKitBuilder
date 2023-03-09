//
//  DynamicFontService.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//


import AppKit
import Foundation

import DSFValueBinders

/// A service for managing scalable fonts
///
/// This services provides a register for components that require dynamically sizable fonts, along with a
/// set of pre-built `DynamicFont`s loosely based on the NSFont's built-in types
///
/// **Custom fonts**
///
/// To use a custom dynamic font, you need to add it to the service's font register,
///
/// ```swift
/// let dynFont2 = DynamicFontService.shared.add(.body.size(16).weight(.light))
/// ```
///
/// Then, you can use this font wherever `.dynamicFont` modifier is available
///
/// ```swift
/// self.contentView.element = Group(layoutType: .center) {
///    Label(String.localized("No selection"))
///       .dynamicFont(.system)
/// }
/// ```
public class DynamicFontService {
	public static let shared = DynamicFontService()

	/// Add a new scalable font based on a provided font
	public func add(_ font: AKBFont) -> DynamicFont {
		let f = DynamicFont(font)
		f.currentScale = self.currentScale.wrappedValue
		self.fonts.append(f)
		return f
	}

	/// Change the scale for the dynamic fonts
	public func scale(by fraction: Double) {
		self.currentScale.wrappedValue = fraction
	}

	// The current scale binder
	public private(set) lazy var currentScale = ValueBinder<Double>(1.0) { [weak self] newValue in
		guard let `self` = self else { return }
		self.isUpdating.whileLocked {
			self._scale(by: newValue)
		}
	}

	// The scalable fonts
	private lazy var fonts: [DynamicFont] = DynamicFont.DefaultFonts
	// The components that have requested dynamic font changes
	private var registered: [RegisteredUpdate] = []
	// To prevent re-entrant changes
	private var isUpdating = ProtectedLock()
}

extension DynamicFontService {
	class RegisteredUpdate {
		internal init(object: AnyObject?, font: DynamicFont?, block: ((NSFont) -> Void)? = nil) {
			self.object = object
			self.font = font
			self.block = block
		}

		weak var object: AnyObject?
		weak var font: DynamicFont?
		var block: ((NSFont) -> Void)?
	}

	func register(_ object: AnyObject, font: DynamicFont, block: @escaping (NSFont) -> Void) {
		let obj = RegisteredUpdate(object: object, font: font, block: block)
		self.registered.append(obj)

		block(font.currentFont)
	}

	func deregister(_ object: AnyObject) {
		self.registered = self.registered.filter { $0.object !== object && $0.object != nil }
	}

	func dynamicFont(for font: AKBFont) -> DynamicFont? {
		return self.fonts.first(where: { $0.templateFont === font })
	}
	
	// Scale all the fonts registered by the service by a fractional amount
	func _scale(by fraction: Double) {
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			// Scale all the font definitions
			self.fonts.forEach { $0.scale(by: fraction) }
			// Go through each registration and tell it to update the font
			self.registered.forEach { reg in
				if let newfont = reg.font?.currentFont {
					reg.block?(newfont)
				}
			}
		}
	}
}
