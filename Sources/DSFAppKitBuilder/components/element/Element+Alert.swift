//
//  Element+Alert.swift
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
import AppKit.NSView
import DSFValueBinders

// MARK: - Presenting an alert

extension Element {
	/// Attach an alert to this element
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - alertBuilder: A block that builds the NSAlert instance when it is to be presented on screen
	///   - builder: A builder for creating the sheet content
	/// - Returns: self
	public func alert(
		isVisible: ValueBinder<Bool>,
		alertBuilder: @escaping () -> NSAlert,
		onDismissed: @escaping (NSApplication.ModalResponse) -> Void
	) -> Self {
		let alertInstance = AlertInstance(
			parent: self,
			alertBuilder: alertBuilder,
			isVisible: isVisible,
			onDismissed: onDismissed
		)

		self.attachedObjects.append(alertInstance)
		return self
	}
}


private class AlertInstance {
	init(
		parent: Element,
		alertBuilder: @escaping () -> NSAlert,
		isVisible: ValueBinder<Bool>,
		onDismissed: @escaping (NSApplication.ModalResponse) -> Void
	) {
		self.parent = parent
		self.alertBuilder = alertBuilder
		self.isVisible = isVisible
		self.onDismissBlock = onDismissed

		isVisible.register(self) { [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentAlert()
			}
			else {
				self.dismissAlert()
			}
		}
	}

	deinit {
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("AlertInstance: deinit")
		}

		// If the alert is visible, dismiss it
		self.dismissAlert()
		self.isVisible.deregister(self)
		self.alertBuilder = nil
	}

	weak var parent: Element?

	// The current NSAlert instance, or `nil` if no alert is presented
	var currentAlert: NSAlert?
	// The function to use when building the alert for display
	var alertBuilder: (() -> NSAlert)?
	let isVisible: ValueBinder<Bool>
	let onDismissBlock: (NSApplication.ModalResponse) -> Void
}

private extension AlertInstance {
	func presentAlert() {
		DispatchQueue.main.async { [weak self] in
			guard
				let `self` = self,
				self.currentAlert == nil,
				let parentWindow = self.parent?.view().window,
				let alertBuilder = self.alertBuilder
			else {
				return
			}
			self.currentAlert = alertBuilder()
			self.currentAlert?.beginSheetModal(for: parentWindow) { [weak self] modalResponse in
				guard let `self` = self else { return }
				self.isVisible.wrappedValue = false
				self.onDismissBlock(modalResponse)
			}
		}
	}

	func dismissAlert() {
		DispatchQueue.main.async { [weak self] in
			guard
				let `self` = self,
				let currentAlert = self.currentAlert,
				let parentWindow = self.parent?.view().window
			else {
				return
			}
			parentWindow.endSheet(currentAlert.window)
			self.currentAlert = nil
		}
	}
}
