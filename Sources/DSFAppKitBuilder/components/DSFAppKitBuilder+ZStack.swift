//
//  DSFAppKitBuilder+ZStack.swift
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

import AppKit.NSView

/// Embed a stack of elements within the element.
///
/// Each additional ZLayer is installed in front of the previous zlayer.
///
/// Usage:
///
/// ```swift
/// lazy var body: Element =
///   ZStack {
///      ZLayer {
///         ImageView(myImage)
///            .horizontalPriorities(compressionResistance: 10)
///            .verticalPriorities(compressionResistance: 10)
///            .scaling(.scaleProportionallyUpOrDown)
///      }
///      ZLayer {
///         VStack(alignment: .centerX) {
///            EmptyView()
///            Label("Apple Computer")
///               .font(NSFont.boldSystemFont(ofSize: 32))
///            EmptyView().height(12)
///         }
///      }
///      ZLayer(layoutType: .center) {
///         Button(title: "Do it!", bezelStyle: .regularSquare)
///            .additionalAppKitControlSettings { (b: NSButton) in
///               b.font = NSFont.boldSystemFont(ofSize: 24)
///            }
///      }
///   }
/// ```
public class ZStack: Element {
	/// Create a ZStack element using a ZLayerBuilder
	public init(edgeInset: CGFloat = 0, @ZLayersBuilder builder: () -> [ZLayer]) {
		let layers = builder()

		super.init()

		layers.forEach { layer in
			let element = layer.element
			let v = element.view()

			self.elements.append(element)
			containerView.addSubview(v)
			switch layer.layoutType {
			case .pinEdges:
				v.pinEdges(to: containerView, edgeInset: edgeInset)
			case .center:
				v.center(in: containerView, edgeInset: edgeInset)
			}
		}
	}

	// Private
	public override func view() -> NSView { return self.containerView }
	private let containerView = NSView()
	private var elements: [Element] = []
}

// MARK: - ZLayer definition

/// Represents a Layer element within a ZStack
public class ZLayer {
	/// Create a new layer in a ZStack
	/// - Parameters:
	///   - layoutType: How the new zlayer lays out within the ZStack bounds
	///   - builder: The element to add to the zlayer
	public init(layoutType: EmbeddedLayoutType = .pinEdges, _ builder: () -> Element) {
		self.layoutType = layoutType
		self.element = builder()
	}

	// Private
	fileprivate let element: Element
	fileprivate let layoutType: EmbeddedLayoutType
}

// MARK: - Result Builder for ZLayers

#if swift(<5.3)
@_functionBuilder
public enum ZLayersBuilder {
	static func buildBlock() -> [ZLayer] { [] }
}
#else
@resultBuilder
public enum ZLayersBuilder {
	static func buildBlock() -> [ZLayer] { [] }
}
#endif

public extension ZLayersBuilder {
	static func buildBlock(_ settings: ZLayer...) -> [ZLayer] {
		settings
	}
}
