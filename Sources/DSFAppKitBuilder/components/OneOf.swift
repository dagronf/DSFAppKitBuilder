//
//  OneOf.swift
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
import DSFValueBinders
import Foundation

/// An element representing multiple child elements of which only one can be visible at a time
///
/// Example usage:
///
/// ```swift
/// OneOf(__visible) {
///   HStack(spacing: 2) {
///      Label("x:")
///      TextField().width(40)
///      Stepper()
///   }
///   HStack {
///      HStack(spacing: 2) {
///         Label("x:")
///         TextField().width(40)
///      }
///      HStack(spacing: 2) {
///         Label("y:")
///         TextField().width(40)
///      }
///   }
///   HStack {
///      HStack(spacing: 2) {
///         Label("x:")
///         TextField().width(40)
///      }
///      HStack(spacing: 2) {
///         Label("y:")
///         TextField().width(40)
///      }
///      HStack(spacing: 2) {
///         Label("z:")
///         TextField().width(40)
///      }
///   }
/// }
/// ```
public class OneOf: Element {
	/// Create a OneOf
	/// - Parameters:
	///   - visibleIndexBinder: A binder to the child index that is visible
	///   - builder: The content
	public init(
		_ visibleIndexBinder: ValueBinder<Int>,
		@OneOfBuilder builder: () -> [Element]
	) {
		self.visibleIndexBinder = visibleIndexBinder
		self.childViews = builder().map { $0.view() }
		super.init()
		self.rootView.translatesAutoresizingMaskIntoConstraints = false
		visibleIndexBinder.register(self) { [weak self] newValue in
			self?.updateVisibility(newValue)
		}
	}

	deinit {
		self.visibleIndexBinder?.deregister(self)
		self.visibleIndexBinder = nil
	}

	override public func view() -> NSView { self.rootView }

	private let rootView = NSView()
	private let childViews: [NSView]
	private var visibleIndexBinder: ValueBinder<Int>?
	private weak var currentView: NSView?
}

private extension OneOf {
	private func updateVisibility(_ index: Int) {
		if let v = self.currentView {
			v.removeFromSuperview()
		}

		guard (0 ..< self.childViews.count).contains(index) else {
			return
		}
		let newView = self.childViews[index]

		CATransaction.begin()
		self.rootView.addSubview(newView)
		newView.pinEdges(to: self.rootView)
		self.currentView = newView
		CATransaction.commit()
	}
}

@resultBuilder
public enum OneOfBuilder {
	static func buildBlock() -> [Element] { [] }
}

/// A resultBuilder to build menus
public extension OneOfBuilder {
	static func buildBlock(_ settings: Element...) -> [Element] {
		settings
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import DSFMenuBuilder
import SwiftUI

let __visible = ValueBinder(0)
@available(macOS 10.15, *)
struct OneOfViewPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				HStack {
					PopupButton {
						MenuItem("first")
						MenuItem("second")
						MenuItem("third")
					}
					.bindSelection(__visible)
					EmptyView()
					OneOf(__visible) {
						HStack(spacing: 0) {
							Label("x:")
							TextField().width(40)
							Stepper()
						}
						HStack {
							HStack(spacing: 0) {
								Label("x:")
								TextField().width(40)
								Stepper()
							}
							HStack(spacing: 0) {
								Label("y:")
								TextField().width(40)
								Stepper()
							}
						}
						HStack {
							HStack(spacing: 0) {
								Label("x:")
								TextField().width(40)
								Stepper()
							}
							HStack(spacing: 0) {
								Label("y:")
								TextField().width(40)
								Stepper()
							}
							HStack(spacing: 0) {
								Label("z:")
								TextField().width(40)
								Stepper()
							}
						}
					}
					.border(width: 0.5, color: NSColor.systemRed)
				}
				EmptyView()
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
