//
//  DSFAppKitBuilder+VisualEffectView.swift
//
//  Created by Darren Ford on 8/8/21
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
	///   - material: The material shown by the visual effect view
	///   - blendingMode: A value indicating how the view’s contents blend with the surrounding content
	///   - builder: The builder to generate the content of the effect view
	///   - isEmphasized: A Boolean value indicating whether to emphasize the look of the material
	public init(
		material: NSVisualEffectView.Material? = nil,
		blendingMode: NSVisualEffectView.BlendingMode? = nil,
		isEmphasized: Bool = false,
		_ builder: () -> Element
	) {
		self.content = builder()
		super.init()

		self.visualView.wantsLayer = true
		self.visualView.translatesAutoresizingMaskIntoConstraints = false
		self.visualView.isEmphasized = isEmphasized
		if let m = material {
			self.visualView.material = m
		}
		if let b = blendingMode {
			self.visualView.blendingMode = b
		}

		let contentView = content.view()

		self.visualView.addSubview(contentView)
		contentView.pinEdges(to: self.visualView)
	}

	deinit {
		isEmphasizedBinder?.deregister(self)
	}

	// Private
	public override func view() -> NSView { return self.visualView }
	private let visualView = NSVisualEffectView()
	private let content: Element

	private var isEmphasizedBinder: ValueBinder<Bool>?
}

// MARK: Bindings

public extension VisualEffectView {
	/// Bind the emphasized state of the visual effect view to a keypath
	func bindIsEmphasized(_ isEmphasizedBinder: ValueBinder<Bool>) -> Self {
		self.isEmphasizedBinder = isEmphasizedBinder
		isEmphasizedBinder.register(self) { [weak self] newValue in
			self?.visualView.isEmphasized = newValue
		}
		return self
	}
}
