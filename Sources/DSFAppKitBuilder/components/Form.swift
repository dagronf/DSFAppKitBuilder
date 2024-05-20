//
//  Form.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

/// A element that simulates a Form
///
/// Usage:
///
/// ```swift
/// @ValueBinding var name: String = ""
/// @ValueBinding var email: String = ""
/// @ValueBinding var language: Int = 0
///
/// lazy var body: Element = {
///    Form(spacerHeight: 8) {
///       Form.Row("Name:", TextField($name))
///       Form.Row("Email:", TextField($email))
///
///       Form.Row.Divider()
///
///       Form.Row(
///          "Language:",
///          PopupButton {
///             MenuItem("English (UK)")
///             MenuItem("Japanese")
///             MenuItem("Te Reo Māori")
///          }
///          .bindSelection(self.$language)
///       )
///    }
/// }
/// ```
public class Form: Element {
	/// Create a Form
	/// - Parameters:
	///   - columnSpacing: The spacing between the label and value columns
	///   - rowSpacing: The default spacing between form rows
	///   - defaultSpacerHeight: The spacing to use for a row spacer
	///   - builder: The row builder
	public init(
		columnSpacing: CGFloat? = nil,
		rowSpacing: CGFloat? = nil,
		spacerHeight: CGFloat = 8,
		@FormRowBuilder builder: () -> [Form.Row]
	) {
		self.rows = builder()
		self.columnSpacing = columnSpacing
		self.rowSpacing = rowSpacing
		self.spacerHeight = spacerHeight
		super.init()
		self.setup()
	}

	private let gridView: NSGridView = {
		let v = NSGridView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setContentHuggingPriority(.defaultLow, for: .horizontal)
		v.setContentHuggingPriority(.defaultHigh, for: .vertical)
		return v
	}()

	private var columnSpacing: CGFloat?
	private var rowSpacing: CGFloat?
	private var spacerHeight: CGFloat = 8

	private let rows: [Form.Row]
	override public func view() -> NSView { self.gridView }
	private var _childElements: [Element] = []
	override public func childElements() -> [Element] { self._childElements }
}

private extension Form {
	func setup() {
		if let rowSpacing = rowSpacing {
			self.gridView.rowSpacing = rowSpacing
		}
		if let columnSpacing = columnSpacing {
			self.gridView.columnSpacing = columnSpacing
		}

		rows.forEach { item in
			let spacing = item.spacing ?? spacerHeight
			if item.displayElement is Divider {
				// Put in a divider
				let b = HDivider()
					.padding(spacing)
					.view()

				let row = self.gridView.addRow(with: [b])
				row.mergeCells(in: NSRange(location: 0, length: 2))
			}
			else if item.displayElement is EmptyView {
				let row = self.gridView.addRow(with: [NSView()])
				row.height = spacing
			}
			else {
				let title: NSView
				if let binder = item.labelBinder {
					let e = DSFAppKitBuilder.Label(binder)
						.horizontalHuggingPriority(.defaultHigh)
					_childElements.append(e)
					title = e.view()
				}
				else if let t = item.label {
					let e = DSFAppKitBuilder.Label(t)
						.horizontalHuggingPriority(.defaultHigh)
					_childElements.append(e)
					title = e.view()
				}
				else {
					title = NSGridCell.emptyContentView
				}

				let element = item.displayElement
				let row = self.gridView.addRow(with: [title, element.view()])
				row.rowAlignment = .firstBaseline

				_childElements.append(element)
			}
		}

		self.gridView.column(at: 0).xPlacement = .trailing
		self.gridView.column(at: 1).xPlacement = .leading
	}
}

// MARK: - Modifiers

public extension Form {
	/// Set the row spacing for the form
	/// - Parameter value: The row spacing
	/// - Returns: self
	func rowSpacing(_ value: CGFloat) -> Self {
		self.gridView.rowSpacing = value
		return self
	}

	/// Set the column spacing for the form
	/// - Parameter value: The row spacing
	/// - Returns: self
	func columnSpacing(_ value: CGFloat) -> Self {
		self.gridView.columnSpacing = value
		return self
	}
}

// MARK: - A form row

public extension Form {
	/// A form row
	class Row {
		/// Returns an empty space for the form
		/// - Parameter spacing: The vertical height for the spacer
		/// - Returns: A new form row
		public static func Spacer(spacing: CGFloat? = nil) -> Form.Row {
			Form.Row(isDivider: false, spacing: spacing)
		}

		/// Returns a horizontal divider for the form
		/// - Parameter spacing: The vertical height for the divider
		/// - Returns: A new form row
		public static func Divider(spacing: CGFloat? = nil) -> Form.Row {
			Form.Row(isDivider: true, spacing: spacing)
		}

		/// Create a row containing a value element only (no label)
		/// - Parameters:
		///   - displayElement: The value element
		public init(_ displayElement: Element) {
			self.label = nil
			self.displayElement = displayElement
			self.spacing = nil
		}

		/// Create a row containing a value element only (no label)
		/// - Parameters:
		///   - builder: The value builder
		public init(@ElementBuilder _ builder: () -> Element) {
			self.label = nil
			self.displayElement = builder()
			self.spacing = nil
		}

		///  Create a form row containing a label and a value element
		/// - Parameters:
		///   - label: The label for the row
		///   - displayElement: The value element
		public init(_ label: String, _ displayElement: Element) {
			self.label = label
			self.displayElement = displayElement
			self.spacing = nil
		}

		/// Create a form row containing a label and a value builder
		/// - Parameters:
		///   - label: The row label
		///   - builder: The value builder
		public init(_ label: String, @ElementBuilder builder: () -> Element) {
			self.label = label
			self.displayElement = builder()
			self.spacing = nil
		}

		/// Create a form row containing a bindable label and a value element
		/// - Parameters:
		///   - label: The bindable label text
		///   - displayElement: The value element
		public init(_ label: ValueBinder<String>, _ displayElement: Element) {
			self.label = nil
			self.labelBinder = label
			self.displayElement = displayElement
			self.spacing = nil
		}

		/// Create a form row containing a bindable label and a value element
		/// - Parameters:
		///   - label: The bindable label text
		///   - builder: The value builder
		public init(_ labelBinder: ValueBinder<String>, @ElementBuilder builder: () -> Element) {
			self.label = nil
			self.labelBinder = labelBinder
			self.displayElement = builder()
			self.spacing = nil
		}

		// private

		private init(isDivider: Bool, spacing: CGFloat? = nil) {
			self.label = nil
			self.labelBinder = nil
			self.displayElement = isDivider ? VDivider() : EmptyView()
			self.spacing = spacing
		}

		let label: String?
		let displayElement: Element
		let spacing: CGFloat?
		var labelBinder: ValueBinder<String>?
	}
}

// MARK: - Result Builder for form elements

@resultBuilder
public enum FormRowBuilder {
	static func buildBlock() -> [Form.Row] { [] }
}

public extension FormRowBuilder {
	static func buildBlock(_ settings: Form.Row...) -> [Form.Row] { settings }
}

// MARK: - SwiftUI preview

#if canImport(SwiftUI)
import SwiftUI
import DSFMenuBuilder

@available(macOS 11, *)
struct BasicFormPreview: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			DSFAppKitBuilder.Form {
				Form.Row(
					"First Row:",
					DSFAppKitBuilder.TextField("Wheeeee!")
				)
				Form.Row(
					"User language:",
					PopupButton {
						MenuItem("English (UK)")
						MenuItem("Japanese")
						MenuItem("Te Reo Māori")
					}
			 	)
				Form.Row(
					"Selection:",
					RadioGroup() {
						RadioElement("first")
						RadioElement("second")
						RadioElement("third")
					}
				)

				Form.Row.Divider()

				Form.Row(
					CheckBox("Enable Notifications")
						.verticalHuggingPriority(.defaultHigh)
				)
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
