//
//  Button.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFValueBinders

public class ButtonBuilder: ViewTestBed {
	var title: String { String.localized("Button") }
	var type: String { "Button" }
	var description: String { String.localized("An Element that displays a button") }
	func build() -> ElementController {
		ButtonBuilderController()
	}
}

class ButtonBuilderController: ElementController {

	let _switch = ValueBinder(true)

	static let monoFontType: NSFont = {
		if #available(macOS 10.15, *) {
			return NSFont.monospacedSystemFont(ofSize: 14, weight: .medium)
		} else {
			return NSFont.systemFont(ofSize: 14, weight: .heavy)
		}
	}()

	private lazy var customStyle = FlatButton.Style(
		borderWidth: 2,
		color: NSColor.systemGreen,
		borderColor: NSColor.systemBlue,
		textColor: NSColor.black,
		font: Self.monoFontType
	)

	lazy var body: Element = {
		VStack(spacing: 16) {
			self.buildButtonBezels()
			HDivider()
			HStack(spacing: 16) {
				self.buildButtonType()
				VDivider()
				self.buildButtonTint()
				DSFAppKitBuilder.EmptyView()
			}

			HDivider()

			VStack {
				Flow {
					FlatButton(title: "#earth-large 大的")
						.controlSize(.large)
					FlatButton(title: "#earth-regular 常规的")
						.controlSize(.regular)
					FlatButton(title: "#earth-small 小的")
						.controlSize(.small)
					FlatButton(title: "#earth-mini 小型的")
						.controlSize(.mini)
				}

				Flow {
					FlatButton(title: "🤔 thinking emoji", style: customStyle)
					FlatButton(title: "sauna 🧖‍♂️", style: customStyle)
					FlatButton(title: "🤩❤️🔒⬆︎🏀", style: customStyle)
					FlatButton(title: "شلال كبير", style: customStyle)
				}
			}
			.hugging(h: 10)

			HDivider()

			HStack {
				Box("Switches") {
					Grid {
						GridRow(rowAlignment: .firstBaseline) {
							Label(".large").font(.monospaced)
							CompatibleSwitch(onOffBinder: _switch)
							CompatibleSwitch(onOffBinder: _switch.toggled())
								.isEnabled(false)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".regular").font(.monospaced)
							CompatibleSwitch(onOffBinder: _switch)
							CompatibleSwitch(onOffBinder: _switch.toggled())
								.isEnabled(false)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".small").font(.monospaced)
							CompatibleSwitch(onOffBinder: _switch)
								.controlSize(.small)
							CompatibleSwitch(onOffBinder: _switch.toggled())
								.isEnabled(false)
								.controlSize(.small)
						}
						GridRow(rowAlignment: .firstBaseline) {
							Label(".mini").font(.monospaced)
							CompatibleSwitch(onOffBinder: _switch)
								.controlSize(.mini)
							CompatibleSwitch(onOffBinder: _switch.toggled())
								.isEnabled(false)
								.controlSize(.mini)
						}
					}
					.columnFormatting(xPlacement: .trailing, trailingPadding: 8, atColumn: 0)
				}
				DSFAppKitBuilder.EmptyView()

//				HStack(alignment: .leading) {
//					Label("Switches:")
//					CompatibleSwitch(onOffBinder: _switch)
//					CompatibleSwitch(onOffBinder: _switch.toggled())
//						.isEnabled(false)
//				}
//				.hugging(h: 10)
			}
			.horizontalHuggingPriority(10)

			DSFAppKitBuilder.EmptyView()
		}
	}()

	func buildButtonBezels() -> Element {
		HStack {
			Grid(columnSpacing: 20) {
				GridRow(rowAlignment: .firstBaseline) {
					Label("Bezel Style").font(.title2)
					Label("Preview").font(.title2)
					Label("Var Height").font(.title2)
					Label("Multiline").font(.title2)
					Label("Bezel Color?").font(.title2)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".circular").font(.monospaced)
					Button(title: "", bezelStyle: .circular)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".disclosure").font(.monospaced)
					Button(title: "", bezelStyle: .disclosure)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".helpButton").font(.monospaced)
					Button(title: "", bezelStyle: .helpButton)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".inline").font(.monospaced)
					Button(title: "My Button", bezelStyle: .inline)
					Label("✅")
					Button(title: "Line One\nLine Two", bezelStyle: .inline)
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".recessed").font(.monospaced)
					Button(title: "My Button", bezelStyle: .recessed)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".regularSquare").font(.monospaced)
					Button(title: "My Button", bezelStyle: .regularSquare)
					Label("✅")
					//Label("✅")
					Button(title: "Line One\nLine Two", bezelStyle: .regularSquare)
					Button(title: "Line One\nLine Two", bezelStyle: .regularSquare)
						.bezelColor(NSColor.systemRed)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".rounded").font(.monospaced)
					Button(title: "My Button", bezelStyle: .rounded)
					Label("-")
					Label("-")
					Button(title: "My Button", bezelStyle: .rounded)
						.bezelColor(NSColor.systemRed)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".roundedDisclosure").font(.monospaced)
					Button(title: "", bezelStyle: .roundedDisclosure)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".roundRect").font(.monospaced)
					Button(title: "My Button", bezelStyle: .roundRect)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".shadowlessSquare").font(.monospaced)
					Button(title: "My Button", bezelStyle: .shadowlessSquare)
					Label("-")
					Button(title: "Line One\nLine Two", bezelStyle: .shadowlessSquare)
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".smallSquare").font(.monospaced)
					Button(title: "My Button", bezelStyle: .smallSquare)
					Label("✅")
					Button(title: "Line One\nLine Two", bezelStyle: .smallSquare)
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".texturedRounded").font(.monospaced)
					Button(title: "My Button", bezelStyle: .texturedRounded)
					Label("-")
					Label("-")
					Label("-")
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".texturedSquare").font(.monospaced)
					Button(title: "My Button", bezelStyle: .texturedSquare)
					Label("-")
					Button(title: "Line One\nLine Two", bezelStyle: .texturedSquare)
					Label("-")
				}
			}
			.columnFormatting(xPlacement: .center, atColumn: 2)
			.columnFormatting(xPlacement: .center, atColumn: 3)
			.columnFormatting(xPlacement: .center, atColumn: 4)
			.cellFormatting(xPlacement: .center, atRowIndex: 0, columnIndex: 2)
			.cellFormatting(xPlacement: .center, atRowIndex: 0, columnIndex: 3)
			.cellFormatting(xPlacement: .center, atRowIndex: 0, columnIndex: 4)

			DSFAppKitBuilder.EmptyView()
		}
	}

	private func buildButtonType() -> Element {
		HStack {
			Grid(columnSpacing: 20) {
				GridRow(rowAlignment: .firstBaseline) {
					Label("Button Type").font(.title2)
					Label("Preview").font(.title2)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".momentaryLight").font(.monospaced)
					Button(title: "Press Me", type: .momentaryLight)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".pushOnPushOff").font(.monospaced)
					Button(title: "Press Me", type: .pushOnPushOff)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".toggle").font(.monospaced)
					Button(title: "Press Me", type: .toggle)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".switch").font(.monospaced)
					Button(title: "Press Me", type: .switch)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".radio").font(.monospaced)
					Button(title: "Press Me", type: .radio)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".momentaryChange").font(.monospaced)
					Button(title: "Press Me", type: .momentaryChange)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".onOff").font(.monospaced)
					Button(title: "Press Me", type: .onOff)
				}
				GridRow(rowAlignment: .firstBaseline) {
					Label(".momentaryPushIn").font(.monospaced)
					Button(title: "Press Me", type: .momentaryPushIn)
				}
			}
			.columnFormatting(xPlacement: .center, atColumn: 1)
		}
	}

	private func buildButtonTint() -> Element {
		if #available(macOS 11, *) {
			return VStack {
				Grid {
					GridRow {
						Label("Image Alignment").font(.title2)
						Label("Preview").font(.title2)
					}
					GridRow {
						Label(".imageLeading").isBordered(false).font(.monospaced)
						Button(title: "Press Me").isBordered(false)
							.font(.title3)
							.image(
								NSImage(named: "apple.logo")!,
								imagePosition: .imageLeading
							)
							.contentTintColor(NSColor.systemGreen)
							.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					}
					GridRow {
						Label(".imageAbove").isBordered(false).font(.monospaced)
						Button(title: "Press Me").isBordered(false)
							.font(.title3)
							.contentTintColor(NSColor.systemRed)
							.image(
								NSImage(named: "apple.logo")!,
								imagePosition: .imageAbove
							)
							.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					}
					GridRow {
						Label(".imageOnly").isBordered(false).font(.monospaced)
						Button(title: "Press Me").isBordered(false)
							.font(.title3)
							.contentTintColor(NSColor.systemBlue)
							.image(
								NSImage(named: "apple.logo")!,
								imagePosition: .imageOnly
							)
							.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					}
					GridRow {
						Label(".imageTrailing").isBordered(false).font(.monospaced)
						Button(title: "Press Me").isBordered(false)
							.font(.title3)
							.contentTintColor(NSColor.systemYellow)
							.image(
								NSImage(named: "apple.logo")!,
								imagePosition: .imageTrailing
							)
							.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					}
					GridRow {
						Label(".imageBelow").isBordered(false).font(.monospaced)
						Button(title: "Press Me").isBordered(false)
							.font(.title3)
							.contentTintColor(NSColor.systemPink)
							.image(
								NSImage(named: "apple.logo")!,
								imagePosition: .imageBelow
							)
							.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					}
					GridRow {
						Label(".imageOverlaps").isBordered(false).font(.monospaced)
						Button(title: "Press Me").isBordered(false)
							.font(.title3)
							.contentTintColor(NSColor.systemTeal)
							.image(
								NSImage(named: "apple.logo")!,
								imagePosition: .imageOverlaps
							)
							.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					}
				}
				.columnFormatting(xPlacement: .center, atColumn: 1)

				DSFAppKitBuilder.EmptyView()
			}
			.hugging(h: 10)
		}
		else {
			return Nothing()
		}
	}
}

// MARK: - SwiftUI previews

#if DEBUG && canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, *)
struct ButtonBuilderPreviews: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			ButtonBuilder().build().body
				.SwiftUIPreview()
		}
		.padding()
	}
}
#endif
