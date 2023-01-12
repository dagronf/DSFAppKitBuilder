//
//  DSFAppKitBuilder+View+SwiftUI.swift
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

#if canImport(SwiftUI)

import AppKit
import SwiftUI

/// Embed a SwiftUI view within the DSL
@available(macOS 10.15, *)
public class SwiftUIView: Element {

	/// Override this in your subclass to provide the root SwiftUI content for the view
	open func rootView() -> some SwiftUI.View {
		return SwiftUI.EmptyView()
	}

	/// Create a hosted SwiftUI control within the DSL
	override public init() {
		super.init()
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		let hostingView = NSHostingView(rootView: self.rootView())
		self.containerView.addSubview(hostingView)
		hostingView.pinEdges(to: self.containerView)
	}

	// Private
	let containerView = NSView()
	public override func view() -> NSView { return containerView }
}

#endif
