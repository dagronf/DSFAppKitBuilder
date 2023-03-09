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
	static let username = Key<String>("username", default: "admin")
	static let password = Key<String>("password", default: "admin")
}

class FirstLastNameViewController: DSFAppKitBuilderViewController {
	// You should never use firstname and lastname to identify users
	// * https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/
	// * https://shinesolutions.com/2018/01/08/falsehoods-programmers-believe-about-names-with-examples/
	// Just being used for demo purposes

	let usernameBinder = ValueBinder<String>(Defaults[.username])

	let passwordBinder = ValueBinder<String>(Defaults[.password])
	let password2Binder = ValueBinder<String>(Defaults[.password])

	// A valuebinder whose output is dependent on the two passwords being equal
	private lazy var passwordsMatch: CombiningValueBuilder = {
		CombiningValueBuilder(self.passwordBinder, self.password2Binder) { $0 == $1 }
	}()

	let canApplyChanges = ValueBinder<Bool>(false)
	let canRevertChanges = ValueBinder<Bool>(false)
	let canResetChanges = ValueBinder<Bool>(false)

	let showPasswords = ValueBinder(false)

	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewDidLoad()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		Swift.print("FirstLastNameViewController: deinit")
	}

	override func viewDidLoad() {
		self.usernameBinder.register() { [weak self] newValue in
			self?.reflectUserChanges()
		}

		self.passwordBinder.register() { [weak self] newValue in
			self?.reflectUserChanges()
		}

		self.password2Binder.register() { [weak self] newValue in
			self?.reflectUserChanges()
		}
	}

	let usernameTitle = NSLocalizedString("Username", comment: "")
	let passwordTitle = NSLocalizedString("Password", comment: "")
	let password2Title = NSLocalizedString("Retype Password", comment: "")

	let resetTitle = NSLocalizedString("Reset", comment: "")
	let revertTitle = NSLocalizedString("Revert", comment: "")
	let applyChangesTitle = NSLocalizedString("Apply Changes", comment: "")

	let headlineFont = DynamicFontService.shared.add(.headline)

	// The view body
	override var viewBody: Element {
		Group(layoutType: .center) {
			VisualEffectView(effect: .init(material: .titlebar), padding: 16) {
				VStack(spacing: 12) {
					HStack(spacing: 12) {
						ImageView().image(NSImage(named: "web-user")!)
							.size(width: 72, height: 72)
						Grid {
							GridRow(rowAlignment: .firstBaseline) {
								Label(self.usernameTitle).dynamicFont(self.headlineFont)
								TextField(self.usernameBinder)
									.placeholderText("username")
									.minWidth(175)
									.dynamicFont(.body).labelPadding(2)
							}
							GridRow(rowAlignment: .firstBaseline) {
								Label(self.passwordTitle).dynamicFont(self.headlineFont)
								SecureTextField(self.passwordBinder, updateOnEndEditingOnly: false)
									.placeholderText("password")
									.minWidth(175)
									.dynamicFont(.body).labelPadding(2)
							}
							GridRow(rowAlignment: .firstBaseline) {
								Label(self.password2Title).dynamicFont(.headline)
								SecureTextField(self.password2Binder, updateOnEndEditingOnly: false)
									.placeholderText("password")
									.minWidth(175)
									.dynamicFont(.body)
									.labelPadding(2)
							}
							GridRow(rowAlignment: .firstBaseline, mergeCells: [0 ... 1]) {
								IfElse(self.passwordsMatch) {
									Label(NSLocalizedString("Passwords match", comment: ""))
								} whenFalse: {
									Label(NSLocalizedString("Passwords don't match", comment: ""))
										.textColor(.systemRed)
								}
							}
						}
						.rowSpacing(8)
						.columnFormatting(xPlacement: .trailing, atColumn: 0)
						.cellFormatting(xPlacement: .center, atRowIndex: 2, columnIndex: 0)
					}

					HDivider()

					HStack() {
						Button(title: self.resetTitle, bezelStyle: .regularSquare) { [weak self] _ in
							self?.resetChanges()
						}
						.bindIsEnabled(self.canResetChanges)
						.dynamicFont(.system)
						EmptyView()
						Button(title: self.revertTitle, bezelStyle: .regularSquare) { [weak self] _ in
							self?.revertChanges()
						}
						.bindIsEnabled(self.canRevertChanges)
						.dynamicFont(.system)
						.hasDestructiveAction(true)
						.bezelColor(.red)

						Button(title: self.applyChangesTitle, bezelStyle: .regularSquare) { [weak self] _ in
							self?.applyChanges()
						}
						.dynamicFont(.system)
						.bindIsEnabled(self.canApplyChanges)
					}
				}
			}
			.cornerRadius(16)
		}
	}
}

extension FirstLastNameViewController {

	private func reflectUserChanges() {
		if !self.passwordsMatch.wrappedValue {
			self.canApplyChanges.wrappedValue = false
			self.canRevertChanges.wrappedValue = true
			self.canResetChanges.wrappedValue = true
		}
		else {
			let usernameOrPasswordChanged =
				self.usernameBinder.wrappedValue != Defaults[.username] ||
				self.passwordBinder.wrappedValue != Defaults[.password]

			if usernameOrPasswordChanged {
				self.canApplyChanges.wrappedValue = true
				self.canRevertChanges.wrappedValue = true
				self.canResetChanges.wrappedValue = true
			}
			else {
				self.canResetChanges.wrappedValue = false
				self.canRevertChanges.wrappedValue = false
				self.canApplyChanges.wrappedValue = false
			}
		}

		let hasChangedFromDefaults =
			Defaults[.username] != Defaults.Keys.username.defaultValue ||
			Defaults[.password] != Defaults.Keys.password.defaultValue

		self.canResetChanges.wrappedValue = hasChangedFromDefaults
	}

	private func revertChanges() {
		self.usernameBinder.wrappedValue = Defaults[.username]
		self.passwordBinder.wrappedValue = Defaults[.password]
		self.password2Binder.wrappedValue = Defaults[.password]
		self.reflectUserChanges()
	}

	private func applyChanges() {
		Defaults[.username] = self.usernameBinder.wrappedValue
		Defaults[.password] = self.passwordBinder.wrappedValue
		self.reflectUserChanges()
	}

	private func resetChanges() {
		Defaults[.username] = Defaults.Keys.username.defaultValue
		Defaults[.password] = Defaults.Keys.password.defaultValue

		self.usernameBinder.wrappedValue = Defaults[.username]
		self.passwordBinder.wrappedValue = Defaults[.password]
		self.password2Binder.wrappedValue = Defaults[.password]

		self.reflectUserChanges()
	}
}

// Demo hook

extension FirstLastNameViewController: ElementController {
	var body: DSFAppKitBuilder.Element { self.viewBody }
}
