//
//  DSFAppKitBuilder+TokenField.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

import Foundation
import AppKit

import DSFValueBinders
import DSFMenuBuilder

/// A string-based Token Field that expands vertically to fit the content as needed
///
/// Usage:
///
/// ```swift
/// private let tokenContent = ValueBinder<[String]>(["red", "green", "blue"])
/// ...
/// TokenField(content: self.tokenField1)
/// ```
public class TokenField: TextField {
	/// Create a TokenField
	/// - Parameters:
	///   - tokenStyle: The token style
	///   - content: The content to display as tokens. Each string in the array becomes a separate token in the field
	///   - updateOnEndEditingOnly: If true, only updates the binding content when the user ends editing in the field
	public init(
		tokenStyle: NSTokenField.TokenStyle = .default,
		content: ValueBinder<[String]>,
		updateOnEndEditingOnly: Bool = false
	) {
		self.content = content
		super.init()

		self.updateOnEndEditingOnly = updateOnEndEditingOnly
		
		self.tokenField.tokenStyle = tokenStyle
		self.tokenField.delegate = self

		self.tokenField.objectValue = content.wrappedValue

		content.register(self) { [weak self] newTokens in
			guard let `self` = self, self.isUpdatingContent == false else { return }
			self.tokenField.objectValue = newTokens
		}
	}

	// Private

	// Called by the base TextField when the content is committed
	override internal func updateContent() {
		self.isUpdatingContent = true
		let tokens = self.tokenField.objectValue as! [String]
		self.content.wrappedValue = tokens
		self.isUpdatingContent = false
	}

	private let content: ValueBinder<[String]>
	private var isUpdatingContent: Bool = false

	override public func view() -> NSView { return self.tokenField }
	private let tokenField = VerticalSizingTokenField()
	//private let updateOnEndEditingOnly: Bool

	public typealias OnEndEditingTokensBlockType = (_ tokens: [String]) -> Void
	private var onEndEditingTokensBlock: OnEndEditingTokensBlockType?

	/// Return the strings which are completions for `substring`
	public typealias CompletionsBlockType = ((_ substring: String) -> [String]?)
	private var completionsBlock: CompletionsBlockType?

	/// Should add [`token`]s at index
	public typealias ShouldAddTokensBlockType = ((_ tokens: [String], _ at: Int) -> [String])
	private var shouldAddTokensBlock: ShouldAddTokensBlockType?

	public typealias HasMenuForTokenBlockType = ((_ token: String) -> Bool)
	private var hasMenuForTokenBlock: HasMenuForTokenBlockType?

	public typealias MenuForTokenBlockType = ((_ token: String) -> Menu?)
	private var menuForTokenBlock: MenuForTokenBlockType?

	public typealias NSMenuForTokenBlockType = ((_ token: String) -> NSMenu?)
	private var nsMenuForTokenBlock: NSMenuForTokenBlockType?
}

// MARK: - Callbacks

public extension TokenField {
	/// A block to return a list of completion strings for this token field
	func completions(_ block: @escaping CompletionsBlockType) -> Self {
		self.completionsBlock = block
		return self
	}

	/// A block to validate any new tokens before they are added to the list
	func shouldAddTokens(_ block: @escaping ShouldAddTokensBlockType) -> Self {
		self.shouldAddTokensBlock = block
		return self
	}

	/// Called when the tokenfield has completed editing and committed the changes
	func onEndEditingTokens(_ block: @escaping OnEndEditingTokensBlockType) -> Self {
		self.onEndEditingTokensBlock = block
		return self
	}
}

// MARK: - Token menu support

public extension TokenField {
	/// A block that gets called to determine whether a particular token has a menu or not
	func hasMenuForToken(_ block: @escaping (_ token: String) -> Bool) -> Self {
		self.hasMenuForTokenBlock = block
		return self
	}

	/// A block to return a Menu (DSFMenuBuilder) for a particular token
	func menuForToken(_ block: @escaping (_ token: String) -> Menu?) -> Self {
		self.menuForTokenBlock = block
		return self
	}

	/// A block to return an NSMenu for a particular token
	func menuForToken(_ block: @escaping (_ token: String) -> NSMenu?) -> Self {
		self.nsMenuForTokenBlock = block
		return self
	}
}

// MARK: - NSTokenFieldDelegate callbacks

extension TokenField: NSTokenFieldDelegate {
	public func tokenField(
		_ tokenField: NSTokenField,
		completionsForSubstring substring: String,
		indexOfToken tokenIndex: Int,
		indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?
	) -> [Any]? {
		if let block = self.completionsBlock {
			selectedIndex?.pointee = -1
			return block(substring)
		}
		return nil
	}

	public func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
		guard let strings = tokens as? [String] else { fatalError("TokenField only supports strings") }
		guard let block = self.shouldAddTokensBlock else { return tokens }
		return block(strings, index)
	}

	public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		if commandSelector == #selector(NSTokenField.insertNewline(_:)) {
			self.updateContent()
		}
		return false
	}

	public override func controlTextDidEndEditing(_ obj: Notification) {
		super.controlTextDidEndEditing(obj)
		self.onEndEditingTokensBlock?(self.content.wrappedValue)
	}
}

extension TokenField {
	public func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
		self.hasMenuForTokenBlock?(representedObject as! String) ?? false
	}

	public func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
		if let block = self.menuForTokenBlock {
			return block(representedObject as! String)?.menu
		}
		else if let block = self.nsMenuForTokenBlock {
			return block(representedObject as! String)
		}
		return nil
	}
}

// MARK: - SwiftUI support

//#if DEBUG && canImport(SwiftUI)
//import SwiftUI
//
//private let __tokenField = ValueBinder<[String]>(["red", "green", "blue"]) { newValue in
//	Swift.print("tokenField newvalue is = \(newValue)")
//}
//
//@available(macOS 10.15, *)
//struct TokenFieldPreviews: PreviewProvider {
//	static var previews: some SwiftUI.View {
//		SwiftUI.VStack {
//			VStack {
//				TokenField(content: __tokenField)
//				EmptyView()
//			}
//			.SwiftUIPreview()
//		}
//	}
//}
//#endif
