//
//  AKBAttributedString.swift
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

public class AKBAttributedString {
	public let attributedString: NSMutableAttributedString
	public var range: NSRange { NSRange(location: 0, length: attributedString.length) }
	public init(_ string: String, font: AKBFont? = nil) {
		self.attributedString = NSMutableAttributedString(string: string)
		if let font = font {
			self.attributedString.addAttributes([.font: font], range: self.range)
		}
	}
}

public extension AKBAttributedString {
	@inlinable func append(_ string: String) -> Self {
		self.attributedString.append(NSAttributedString(string: string))
		return self
	}
	@inlinable func append(_ string: NSAttributedString) -> Self {
		self.attributedString.append(string)
		return self
	}
}

public extension AKBAttributedString {
	@inlinable func underlined(_ style: NSUnderlineStyle = .single) -> Self {
		self.attributedString.addAttributes([.underlineStyle: style.rawValue], range: self.range)
		return self
	}
}
