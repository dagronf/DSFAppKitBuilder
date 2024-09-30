//
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AppKit

/// A view controller that displays the result of executing a builder function
///
/// Usage :-
///
/// ```swift
/// var myViewController = DSFAppKitBuilderAssignableViewController { [weak self] in
///    DSFAppKitBuilder.Label("Wheeee!")
/// }
/// ```
public class DSFAppKitBuilderAssignableViewController: NSViewController {
	public init(_ builder: @escaping () -> Element) {
		self._builder = builder
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func loadView() {
		self.reloadBody()
	}

	/// Rebuild the view from the viewBody
	public func reloadBody() {
		self._displayElement = _builder()
		self.view = self._displayElement?.view() ?? NSView()
	}

	// private

	internal func reset() {
		self._displayElement = nil
		self.rootView.element = Nothing()
	}

	/// The builder block, so it can be
	private let _builder: () -> Element
	private let rootView = DSFAppKitBuilderView()

	// Keep a hold of the display body element, so that it doesn't deinit itself.
	// Internally most items are weakly held so it's the owners responsibility for
	// maintaining its lifecycle
	private var _displayElement: Element?
}
