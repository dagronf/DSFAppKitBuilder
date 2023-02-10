//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFComboButton
import DSFValueBinders
import DSFMenuBuilder

public class ComboButtonBuilder: ViewTestBed {
	var title: String { String.localized("Combo Button") }
	var type: String { "ComboButton" }
	var description: String { String.localized("The ComboButton element displays a combo button") }
	func build() -> ElementController {
		ComboButtonController()
	}
}

class ComboButtonController: ElementController {
	private let menu1: NSMenu = NSMenu {
		MenuItem("one")
			.onAction { Swift.print("one") }
	}
	private let menu2: NSMenu = NSMenu {
		MenuItem("two")
			.onAction { Swift.print("two") }
	}

	private var rabbitComboTitle = ValueBinder("Rabbit")
	private lazy var rabbitMenu: NSMenu = NSMenu {
		MenuItem("first")
			.enabled { [weak self] in true }
			.onAction { [weak self] in self?.rabbitComboTitle.wrappedValue = "first" }
		MenuItem("second")
			.enabled { [weak self] in true }
			.onAction { [weak self] in self?.rabbitComboTitle.wrappedValue = "second" }
		MenuItem("third")
			.enabled { [weak self] in true }
			.onAction { [weak self] in self?.rabbitComboTitle.wrappedValue = "third" }
	}

	private lazy var simpleMenu: NSMenu = NSMenu {
		MenuItem("first")
			.enabled { [weak self] in true }
		MenuItem("second")
			.enabled { [weak self] in true }
		MenuItem("third")
			.enabled { [weak self] in true }
	}

	private var menu2Count = 0

	private let buWidth = 200.0

	func largeCombo(style: DSFComboButton.Style, _ title: String) -> Element {
		if #available(macOS 11.0, *) {
			return ComboButton(style: .split, title, menu: nil).controlSize(.large)
		} else {
			return EmptyView()
		}
	}

	lazy var body: Element = {
		VStack {
			HStack {
				Grid {
					GridRow {
						Label("Large")
						Label("Regular")
						Label("Small")
						Label("Mini")
					}
					GridRow {
						self.largeCombo(style: .split, "Split Style")
						ComboButton(style: .split, "Split Style", menu: nil).controlSize(.regular)
						ComboButton(style: .split, "Split Style", menu: nil).controlSize(.small)
						ComboButton(style: .split, "Split Style", menu: nil).controlSize(.mini)
					}
					GridRow {
						self.largeCombo(style: .split, "Split Style")
						ComboButton(style: .split, "Split Style", menu: nil).controlSize(.regular).isEnabled(false)
						ComboButton(style: .split, "Split Style", menu: nil).controlSize(.small).isEnabled(false)
						ComboButton(style: .split, "Split Style", menu: nil).controlSize(.mini).isEnabled(false)
					}
					GridRow {
						self.largeCombo(style: .unified, "Unified Style")
						ComboButton(style: .unified, "Unified Style", menu: nil).controlSize(.regular)
						ComboButton(style: .unified, "Unified Style", menu: nil).controlSize(.small)
						ComboButton(style: .unified, "Unified Style", menu: nil).controlSize(.mini)
					}
					GridRow {
						self.largeCombo(style: .unified, "Unified Style")
						ComboButton(style: .unified, "Unified Style", menu: nil).controlSize(.regular).isEnabled(false)
						ComboButton(style: .unified, "Unified Style", menu: nil).controlSize(.small).isEnabled(false)
						ComboButton(style: .unified, "Unified Style", menu: nil).controlSize(.mini).isEnabled(false)
					}
				}
				EmptyView()
			}

			HDivider()

			HStack {
				VStack(alignment: .leading) {
					Label("Default")
					ComboButton(style: .split, "Split Style", menu: menu1)
					ComboButton(style: .unified, "Unified Style", menu: menu2)
				}
				VStack {
					Label("Disabled") //.font(.headline)
					ComboButton(style: .split, "Split Style", menu: nil)
						.isEnabled(false)
					ComboButton(style: .unified, "Unified Style", menu: nil)
						.isEnabled(false)
					ComboButton(style: .unified, "Unified Style", menu: nil)
						.bindIsHidden(ValueBinder<Bool>(true))
				}
			}

			HDivider()

			HStack {
				ComboButton(
					style: .split,
					"Split (fixed menu)",
					image: NSImage(named: "house"),
					menu: menu1
				) {
					Swift.print("Split Button pressed!")
				}

				ComboButton(
					style: .unified,
					"Unified (dynamic menu)",
					menu: nil
				) {
					Swift.print("Unified Button pressed!")
				}
				.width(buWidth)
				.generateMenu { [weak self] in
					guard let `self` = self else { return nil }
					let count = self.menu2Count
					self.menu2Count += 1
					return NSMenu {
						MenuItem("first \(count)")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Unified menu selected - first \(count)") }
						MenuItem("second \(count)")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Unified menu selected - second \(count)") }
						MenuItem("third \(count)")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Unified menu selected - third \(count)") }
					}
				}

				ComboButton(
					style: .split,
					"Rabbit",
					image: NSImage(named: "house"),
					menu: nil
				) {
					Swift.print("Unified Button pressed!")
				}
				.generateMenu { [weak self] in
					NSMenu {
						MenuItem("Do Rabbit")
							.enabled { [weak self] in true }
							.onAction { [weak self] in Swift.print("Rabbit be did!") }
					}
				}

				ComboButton(
					style: .unified,
					"Rabbit",
					image: NSImage(named: "fan.oscillation"),
					menu: rabbitMenu
				) { [weak self] in
					if let w = self?.rabbitComboTitle.wrappedValue {
						Swift.print("Unified Button pressed (\(w))!")
					}
				}
				.bindTitle(rabbitComboTitle)
			}
			.visualEffect(.init(material: .sidebar), padding: 12)
			.border(width: 0.5, color: NSColor.textColor)
		}
		.hugging(h: 249)
	}()
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ComboButtonBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			VStack {
				ComboButtonBuilder().build().body
				EmptyView()
			}
			.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
