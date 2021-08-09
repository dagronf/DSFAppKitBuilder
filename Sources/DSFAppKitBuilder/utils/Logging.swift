//
//  Logging.swift
//
//  Created by Darren Ford on 10/8/21
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
import os.log

internal class Logger {
	@inline(__always)
	internal static func Debug(_ str: StaticString) {
		if DSFAppKitBuilder.ShowDebuggingOutput {
			os_log(str, log: OSLog.logger, type: .debug)
		}
	}
}

internal extension OSLog {
	 private static var subsystem = Bundle.main.bundleIdentifier!

	 /// Logs the view cycles like viewDidLoad.
	 static let logger = OSLog(subsystem: subsystem, category: "DSFAppKitBuilder")
}
