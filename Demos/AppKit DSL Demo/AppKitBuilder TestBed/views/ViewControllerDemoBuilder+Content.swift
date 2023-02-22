//
//  ViewControllerDemoBuilder+Content.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 23/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders

import Defaults

extension Defaults.Keys {
	static let firstName = Key<String>("first-name", default: "Amelia")
	static let lastName = Key<String>("last-name", default: "Airhart")
}

class FirstLastNameViewController: DSFAppKitBuilderViewController {
	// You should never use firstname and lastname to identify users
	// * https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/
	// * https://shinesolutions.com/2018/01/08/falsehoods-programmers-believe-about-names-with-examples/
	// Just being used for demo purposes
	let firstNameBinder = ValueBinder<String>(Defaults[.firstName])
	let lastNameBinder = ValueBinder<String>(Defaults[.lastName])

	// The full name ("<firstname> <lastname>") of the user
	// (THIS METHOD OF USER NAMING IS FLAWED. NEVER USE IN PRODUCTION CODE. Purely for demo purposes)
	let fullNameBinder = ValueBinder<String>("")

	// Have there been changes to the user?
	let hasUpdates = ValueBinder<Bool>(false)

	// Is the current name different to the default name?
	let canReset = ValueBinder<Bool>(false)

	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewDidLoad()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		self.firstNameBinder.register() { [weak self] newValue in
			self?.updateFullName()
		}

		self.lastNameBinder.register() { [weak self] newValue in
			self?.updateFullName()
		}
	}

	let firstNameTitle = NSLocalizedString("First Name", comment: "")
	let lastNameTitle = NSLocalizedString("Last Name", comment: "")
	let resetTitle = NSLocalizedString("Reset", comment: "")
	let revertTitle = NSLocalizedString("Revert", comment: "")
	let applyChangesTitle = NSLocalizedString("Apply Changes", comment: "")

	// The view body
	override var viewBody: Element {
		Group(layoutType: .center) {
			VisualEffectView(effect: .init(material: .underPageBackground), padding: 16) {
				VStack(spacing: 12) {
					HStack(spacing: 12) {
						ImageView().image(NSImage(named: "web-user")!)
							.size(width: 72, height: 72)
						Grid {
							GridRow(rowAlignment: .firstBaseline) {
								Label(self.firstNameTitle).font(.headline)
								TextField(self.firstNameBinder, self.firstNameTitle)
									.minWidth(175)
									.font(.body).labelPadding(2)
							}
							GridRow(rowAlignment: .firstBaseline) {
								Label(self.lastNameTitle).font(.headline)
								TextField(self.lastNameBinder, self.lastNameTitle)
									.minWidth(175)
									.font(.body).labelPadding(2)
							}
							GridRow(rowAlignment: .firstBaseline, mergeCells: [0 ... 1]) {
								Label(self.fullNameBinder).font(.body).textColor(.placeholderTextColor)
							}
						}
						.rowSpacing(8)
						.columnFormatting(xPlacement: .trailing, atColumn: 0)
						.cellFormatting(xPlacement: .center, atRowIndex: 2, columnIndex: 0)
					}

					HDivider()

					HStack() {
						Button(title: self.resetTitle) { [weak self] _ in
							self?.resetChanges()
						}
						.bindIsEnabled(self.canReset)
						EmptyView()
						Button(title: self.revertTitle) { [weak self] _ in
							self?.revertChanges()
						}
						.bindIsEnabled(self.hasUpdates)
						.hasDestructiveAction(true)
						.bezelColor(.red)

						Button(title: self.applyChangesTitle) { [weak self] _ in
							self?.applyChanges()
						}
						.bindIsEnabled(self.hasUpdates)
					}
				}
			}
			.cornerRadius(16)
		}
	}
}

extension FirstLastNameViewController {
	private func updateFullName() {
		let n = self.firstNameBinder.wrappedValue + " " + self.lastNameBinder.wrappedValue
		self.fullNameBinder.wrappedValue = n.count == 1 ? "<empty>" : n
		self.updateChangeStatus()
	}

	private func updateChangeStatus() {
		self.hasUpdates.wrappedValue =
			self.firstNameBinder.wrappedValue != Defaults[.firstName] ||
			self.lastNameBinder.wrappedValue != Defaults[.lastName]
		self.canReset.wrappedValue =
			Defaults.Keys.firstName.defaultValue != Defaults[.firstName] ||
			Defaults.Keys.lastName.defaultValue != Defaults[.lastName]
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

	private func resetChanges() {
		Defaults[.firstName] = Defaults.Keys.firstName.defaultValue
		Defaults[.lastName] = Defaults.Keys.lastName.defaultValue
		self.revertChanges()
		self.updateChangeStatus()
	}
}

// Demo hook

extension FirstLastNameViewController: ElementController {
	var body: DSFAppKitBuilder.Element { self.viewBody }
}
