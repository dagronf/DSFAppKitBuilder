//
//  BuilderViewController.swift
//  AppKit DSF ViewController Demo
//
//  Created by Darren Ford on 12/5/2022.
//

import AppKit
import DSFAppKitBuilder
import DSFValueBinders
import Defaults

extension Defaults.Keys {
	static let firstName = Key<String>("first-name", default: "Amelia")
	static let lastName = Key<String>("last-name", default: "Airhart")
}

class BuilderViewController: DSFAppKitBuilderViewController {

	let firstNameBinder = ValueBinder<String>(Defaults[.firstName])
	let lastNameBinder = ValueBinder<String>(Defaults[.lastName])

	let toggleBinder = ValueBinder(false)

	// The full name ("<firstname> <lastname>") of the user
	// (THIS METHOD OF USER NAMING IS FLAWED. NEVER USE IN PRODUCTION CODE. Purely for demo purposes)
	let fullNameBinder = ValueBinder<String>("")

	// Have there been changes to the user?
	let hasUpdates = ValueBinder<Bool>(false)

	override func viewDidLoad() {
		self.firstNameBinder.register() { [weak self] newValue in
			self?.updateFullName()
		}

		self.lastNameBinder.register() { [weak self] newValue in
			self?.updateFullName()
		}
	}

	// The view body
	override var viewBody: Element {
		VStack {
			Label(self.fullNameBinder)
				.font(NSFont.boldSystemFont(ofSize: 16))
			HDivider()

			HStack(spacing: 16) {
				ImageView().image(NSImage(named: "web-user")!)
					.size(width: 48, height: 48)
				Grid {
					GridRow(rowAlignment: .firstBaseline) {
						Label("User's First Name:")
						TextField(self.firstNameBinder, "First Name")
							.minWidth(150)
					}
					GridRow(rowAlignment: .firstBaseline) {
						Label("Last Name:")
						TextField(self.lastNameBinder, "Last Name")
							.minWidth(150)
					}
				}
				.columnFormatting(xPlacement: .trailing, atColumn: 0)
			}
			
			HStack() {
				EmptyView()
				Button(title: "Revert to saved") { [weak self] _ in
					self?.revertChanges()
				}
				.bindIsEnabled(hasUpdates)
				.additionalAppKitControlSettings { (button: NSButton) in
					button.hasDestructiveAction = true
					button.bezelColor = .red
				}

				Button(title: "Apply Changes") { [weak self] _ in
					self?.applyChanges()
				}
				.bindIsEnabled(hasUpdates)
			}
		}
		.edgeInsets(20)
	}
}

extension BuilderViewController {
	private func updateFullName() {
		let n = self.firstNameBinder.wrappedValue + " " + self.lastNameBinder.wrappedValue
		self.fullNameBinder.wrappedValue = n.count == 1 ? "<empty>" : n
		self.updateChangeStatus()
	}

	private func updateChangeStatus() {
		self.hasUpdates.wrappedValue =
			self.firstNameBinder.wrappedValue != Defaults[.firstName] ||
			self.lastNameBinder.wrappedValue != Defaults[.lastName]
	}

	private func revertChanges() {
		self.firstNameBinder.wrappedValue = Defaults[.firstName]
		self.lastNameBinder.wrappedValue = Defaults[.lastName]
	}

	private func applyChanges() {
		Defaults[.firstName] = self.firstNameBinder.wrappedValue
		Defaults[.lastName] = self.lastNameBinder.wrappedValue
		self.updateChangeStatus()
	}
}
