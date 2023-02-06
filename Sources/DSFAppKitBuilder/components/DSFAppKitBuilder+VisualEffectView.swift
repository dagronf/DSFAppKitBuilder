//
//  DSFAppKitBuilder+VisualEffectView.swift
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
import DSFValueBinders

/// A view that adds translucency and vibrancy effects to the views in your interface.
///
/// Usage:

/// ```swift
/// VisualEffectView {
///    VStack {
///       Label("My effect view content!")
///    }
/// }
/// ```
///
/// See: [NSVisualEffectView](https://developer.apple.com/documentation/appkit/nsvisualeffectview)
///
public class VisualEffectView: Element {
	/// Create a visual effect view
	/// - Parameters:
	///   - effect: The effects to apply to the view
	///   - padding: Inset padding for child content
	///   - builder: The builder to generate the content of the effect view
	public convenience init(
		effect: VisualEffect,
		padding: CGFloat? = nil,
		_ builder: () -> Element
	) {
		self.init(
			material: effect.material,
			blendingMode: effect.blendingMode,
			isEmphasized: effect.isEmphasized,
			padding: padding,
			builder
		)
	}

	/// Create a visual effect view
	/// - Parameters:
	///   - material: The material shown by the visual effect view
	///   - blendingMode: A value indicating how the view’s contents blend with the surrounding content
	///   - builder: The builder to generate the content of the effect view
	///   - isEmphasized: A Boolean value indicating whether to emphasize the look of the material
	public init(
		material: NSVisualEffectView.Material? = nil,
		blendingMode: NSVisualEffectView.BlendingMode? = nil,
		isEmphasized: Bool = false,
		padding: CGFloat? = nil,
		_ builder: () -> Element
	) {
		// Make the visual effect view
		self.visualView = VisualEffect.MakeView(
			material: material,
			blendingMode: blendingMode,
			isEmphasized: isEmphasized
		)

		// Build the content
		self.content = builder()

		super.init()

		let contentView = self.content.view()
		self.visualView.addSubview(contentView)

		let inset = padding ?? 0
		contentView.pinEdges(to: self.visualView, edgeInset: inset)
	}

	deinit {
		self.isEmphasizedBinder?.deregister(self)
	}

	// Private
	override public func view() -> NSView { return self.visualView }
	public override func childElements() -> [Element] { return [self.content] }

	private let visualView: NSVisualEffectView
	private let content: Element

	private var isEmphasizedBinder: ValueBinder<Bool>?
}

// MARK: Bindings

public extension VisualEffectView {
	/// Bind the emphasized state of the visual effect view
	func bindIsEmphasized(_ isEmphasizedBinder: ValueBinder<Bool>) -> Self {
		self.isEmphasizedBinder = isEmphasizedBinder
		isEmphasizedBinder.register { [weak self] newValue in
			self?.visualView.isEmphasized = newValue
		}
		return self
	}
}

// MARK: VisualEffect definition

/// A container for the visual effect settings for an NSVisualEffectView
public struct VisualEffect {
	let material: NSVisualEffectView.Material?
	let blendingMode: NSVisualEffectView.BlendingMode?
	let isEmphasized: Bool

	/// Create
	/// - Parameters:
	///   - material: The material to use, or nil to use default
	///   - blendingMode: The blending mode to use, or nil to use default
	///   - isEmphasized: True if the view should be emphasized, or false otherwise
	public init(
		material: NSVisualEffectView.Material? = nil,
		blendingMode: NSVisualEffectView.BlendingMode? = nil,
		isEmphasized: Bool = false
	) {
		self.material = material
		self.blendingMode = blendingMode
		self.isEmphasized = isEmphasized
	}
}

extension VisualEffect {
	// Make a visual effect view from the stored settings
	public func makeView() -> NSVisualEffectView {
		return VisualEffect.MakeView(
			material: self.material,
			blendingMode: self.blendingMode,
			isEmphasized: self.isEmphasized
		)
	}

	// Make a visual effect view using the provided settings
	public static func MakeView(
		material: NSVisualEffectView.Material? = nil,
		blendingMode: NSVisualEffectView.BlendingMode? = nil,
		isEmphasized: Bool = false
	) -> NSVisualEffectView {
		let newView = NSVisualEffectView()
		newView.wantsLayer = true
		newView.translatesAutoresizingMaskIntoConstraints = false
		material.withUnwrapped { newView.material = $0 }
		blendingMode.withUnwrapped { newView.blendingMode = $0 }
		newView.isEmphasized = isEmphasized
		return newView
	}
}
