//
//  SearchField.swift
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

import Foundation
import AppKit
import DSFSearchField
import DSFValueBinders

/// A wrapper for NSSearchField
///
/// Usage:
///
/// ```swift
/// let password = ValueBinder("")
/// ...
/// SecureTextField()
///    .placeholderText("Password")
///    .bindSecureText(self.password)
/// ```
public class SearchField: Control {
	/// Create a search field
	/// - Parameters:
	///   - searchTermBinder:
	///   - initialSearchTerm: The initial text to display in the search field
	///   - recentsAutosaveName: The autosave name for the search field
	///   - placeholderText: The placeholder text to display
	convenience public init(
		initialSearchTerm: String? = nil,
		recentsAutosaveName: String? = nil,
		placeholderText: String? = nil
	) {
		self.init(
			searchTermBinder: nil,
			searchTermUpdateType: nil,
			initialSearchTerm: initialSearchTerm,
			recentsAutosaveName: recentsAutosaveName,
			placeholderText: placeholderText
		)
	}

	/// Create a search field
	/// - Parameters:
	///   - searchTermBinder:
	///   - initialSearchTerm: The initial text to display in the search field
	///   - recentsAutosaveName: The autosave name for the search field
	///   - placeholderText: The placeholder text to display
	convenience public init(
		searchTermBinder: ValueBinder<String>,
		searchBinderUpdateType: UpdateType,
		recentsAutosaveName: String? = nil,
		placeholderText: String? = nil
	) {
		self.init(
			searchTermBinder: searchTermBinder,
			searchTermUpdateType: searchBinderUpdateType,
			initialSearchTerm: nil,
			recentsAutosaveName: recentsAutosaveName,
			placeholderText: placeholderText
		)
	}

	private init(
		searchTermBinder: ValueBinder<String>?,
		searchTermUpdateType: UpdateType?,
		initialSearchTerm: String?,
		recentsAutosaveName: String?,
		placeholderText: String?
	) {
		super.init()
		if let s = recentsAutosaveName { self.searchField.recentsAutosaveName = s }
		self.searchField.placeholderString = placeholderText

		self.searchField.searchTermChangeCallback = { [weak self] newString in
			self?.handleTermChange(newString)
		}

		self.searchField.searchSubmitCallback = { [weak self] newString in
			self?.handleSubmitChange(newString)
		}

		if let initialSearchTerm = initialSearchTerm {
			self.searchField.stringValue = initialSearchTerm
		}

		if let binder = searchTermBinder {
			_ = self.bindSearchTerm(binder, updateType: searchTermUpdateType ?? .all)
		}
	}

	/// The type of updates to reflect in the search term binding
	public enum UpdateType {
		/// Perform binding updates for all changes
		case all
		/// Update search term binding only when the user submits (ie. presses return)
		case submitOnly
	}

	private func handleTermChange(_ newString: String) {
		self.changeBlock?(newString)
		if self.searchTermBindingUpdateType != .submitOnly {
			self.searchTermBinder?.wrappedValue = newString
		}
	}

	private func handleSubmitChange(_ newString: String) {
		self.submitBlock?(newString)
		self.searchTermBinder?.wrappedValue = newString
	}

	deinit {
		self.submitBlock = nil
		self.changeBlock = nil
		self.searchTermBinder = nil
	}

	private let searchField = DSFSearchField(frame: .zero, recentsAutosaveName: nil)
	public override func view() -> NSView { return self.searchField }

	private var submitBlock: ((String) -> Void)?
	private var changeBlock: ((String) -> Void)?
	private var searchTermBinder: ValueBinder<String>?
	private var searchTermBindingUpdateType: UpdateType?
}

public extension SearchField {
	/// Set a callback block for when the content of the search field changes
	func onChange(_ block: @escaping (String) -> Void) -> Self {
		self.changeBlock = block
		return self
	}

	/// Set a callback block for when the content of the search field submits (ie. the user presses return in the field)
	func onSubmit(_ block: @escaping (String) -> Void) -> Self {
		self.submitBlock = block
		return self
	}
}

public extension SearchField {
	/// Bind the field's value to the ValueBinder
	/// - Parameters:
	///   - searchTermBinder: The binding for the search text
	///   - updateType: When does the binding update?
	/// - Returns: Self
	func bindSearchTerm(_ searchTermBinder: ValueBinder<String>, updateType: UpdateType = .all) -> Self {
		self.searchTermBinder = searchTermBinder
		self.searchTermBindingUpdateType = updateType
		searchTermBinder.register { [weak self] newValue in
			self?.searchField.stringValue = newValue
		}
		return self
	}
}

#if DEBUG && canImport(SwiftUI)

let __searchText = ValueBinder("")
let __searchSubmittedText = ValueBinder("")
let __searchText2 = ValueBinder("")
let __searchSubmittedText2 = ValueBinder("")

import SwiftUI
@available(macOS 10.15, *)
struct SearchFieldPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.VStack {
			VStack(alignment: .leading) {
				Box("Value binding updates") {
					VStack(alignment: .leading) {
						SearchField()
							.bindSearchTerm(__searchText, updateType: .all)
							.onSubmit { newValue in
								__searchSubmittedText.wrappedValue = newValue
							}
						HStack {
							Label("Search text:")
							TextField()
								.bindText(__searchText)
							Label("Last submit:")
							Label()
								.bindLabel(__searchSubmittedText.stringValue(emptyPlaceholderString: "<empty>"))
						}
					}
				}
				.titleFont(.headline)
				.horizontalHuggingPriority(.init(10))

				Box("Binding update on submit only") {
					VStack(alignment: .leading) {
						SearchField()
							.bindSearchTerm(__searchText2, updateType: .submitOnly)
							.onSubmit { newValue in
								__searchSubmittedText2.wrappedValue = newValue
							}
						HStack {
							Label("Search text:")
							TextField()
								.bindText(__searchText2)
							Label("Last submit:")
							Label()
								.bindLabel(__searchSubmittedText2.stringValue(emptyPlaceholderString: "<empty>"))
						}
					}
				}
				.titleFont(.headline)
				.horizontalHuggingPriority(.init(10))

				HDivider()
				HStack {
					Label("Show placeholder text")
					SearchField(placeholderText: "Type something…")
				}
				HStack {
					Label("Set initial value")
					SearchField(
						initialSearchTerm: "caterpillar",
						placeholderText: "Search for something meaningful…"
					)
				}
			}
			.SwiftUIPreview()
			.padding()
		}
	}
}
#endif
