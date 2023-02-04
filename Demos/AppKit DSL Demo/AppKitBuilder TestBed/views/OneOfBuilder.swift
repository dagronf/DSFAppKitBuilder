//
//  OneOfBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit

import DSFAppearanceManager
import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

public class OneOfBuilder: ViewTestBed {
	var title: String { "One Of" }
	var description: String { "An Element that allows the user to display exactly one of the child elements at any time" }
	func build() -> ElementController {
		OneOfBuilderController()
	}
}

class OneOfBuilderController: ElementController {
	deinit {
		Swift.print("OneOfBuilderController: deinit")
	}

	let __visible = ValueBinder(0)

	lazy var body: Element = {
		VStack(alignment: .leading) {
			Box("", titlePosition: .noTitle) {
				HStack {
					PopupButton {
						MenuItem("Scalar")
						MenuItem("2D Coordinate")
						MenuItem("3D Coordinate")
					}
					.bindSelection(__visible)

					EmptyView()

					OneOf(__visible) {
						HStack(spacing: 2) {
							Label("x:")
							TextField().width(40)
							Stepper()
						}
						HStack {
							HStack(spacing: 2) {
								Label("x:")
								TextField().width(40)
								Stepper()
							}
							HStack(spacing: 2) {
								Label("y:")
								TextField().width(40)
								Stepper()
							}
						}
						HStack {
							HStack(spacing: 2) {
								Label("x:")
								TextField().width(40)
								Stepper()
							}
							HStack(spacing: 2) {
								Label("y:")
								TextField().width(40)
								Stepper()
							}
							HStack(spacing: 2) {
								Label("z:")
								TextField().width(40)
								Stepper()
							}
						}
					}
					.padding(4)
					.cornerRadius(8)
					.border(width: 0.5, color: NSColor.quaternaryLabelColor)
					.backgroundColor(DSFAppearanceCache.shared.accentColor.withAlphaComponent(0.1))
				}
			}
			.horizontalHuggingPriority(10)
			EmptyView()
		}
	}()
}
