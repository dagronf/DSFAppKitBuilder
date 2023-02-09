//
//  TrackingArea.swift
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

/// A tracking area that tracks a view
final class TrackingArea {
	/**
	- Parameters:
		- view: The view to add tracking to.
		- rect: The area inside the view to track. Defaults to the whole view (`view.bounds`).
	*/
	init(
		for view: NSView,
		rect: CGRect? = nil,
		options: NSTrackingArea.Options = []
	) {
		self.view = view
		self.rect = rect ?? view.bounds
		self.options = options
	}

	/**
	Updates the tracking area.
	- Note: This should be called in your `NSView#updateTrackingAreas()` method.
	*/
	func update() {
		if let trackingArea = self.trackingArea {
			self.view?.removeTrackingArea(trackingArea)
		}

		let newTrackingArea = NSTrackingArea(
			rect: self.rect,
			options: [
				.mouseEnteredAndExited,
				.activeInActiveApp
			],
			owner: self.view,
			userInfo: nil
		)

		self.view?.addTrackingArea(newTrackingArea)
		self.trackingArea = newTrackingArea
	}

	// Private

	private weak var view: NSView?
	private let rect: CGRect
	private let options: NSTrackingArea.Options
	private var trackingArea: NSTrackingArea?
}
