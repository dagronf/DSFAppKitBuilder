//
//  GridBuilder.swift
//  AppKitBuilder TestBed
//
//  Created by Darren Ford on 2/2/2023.
//

import Foundation
import AppKit

import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

public class FormBuilder: ViewTestBed {
	var title: String { String.localized("Form") }
	var type: String { "Form" }
	var description: String { String.localized("A form control") }
	func build() -> ElementController {
		FormBuilderController()
	}
}

let numberFormatter: NumberFormatter = {
	 let formatter = NumberFormatter()
	 formatter.numberStyle = .decimal
	 return formatter
}()

class FormBuilderController: ElementController {

	@ValueBinding var name: String = ""
	@ValueBinding var password: String = ""
	@ValueBinding var email: String = ""
	@ValueBinding var enableNotifications: Bool = false
	@ValueBinding var aggressive: Bool = false
	@ValueBinding var excitement: Double = 1.0
	@ValueBinding var language: Int = 0

	@ValueBinding var radioSelection: Int = 2

	@ValueBinding var total: Double = 0

	@ValueBinding var labelIsText: String = "This is text"

	@ValueBinding var ratingValue: Double = 0.0
	let ratingFormatter: NumberFormatter = {
		let f = NumberFormatter()
		f.maximumFractionDigits = 0
		return f
	}()

	deinit {
		Swift.print("FormBuilderController: deinit")
	}

	lazy var body: Element = {
		VStack {
			Form(spacerHeight: 8) {
				Form.Row("Name:", TextField($name).placeholderText("User name"))
				Form.Row("Password:", SecureTextField($password).placeholderText("Password"))
				Form.Row("Email:", TextField($email).placeholderText("User email address"))

				Form.Row.Spacer()

				Form.Row(
					"Language:",
					PopupButton {
						MenuItem("English (UK)")
						MenuItem("Japanese")
						MenuItem("Te Reo Māori")
					}
						.bindSelection(self.$language)
				)
				Form.Row(
					CheckBox("Enable Notifications")
						.bindOnOffState($enableNotifications)
				)
				Form.Row(
					CheckBox("Aggressive").bindOnOffState($aggressive)
						.bindIsEnabled($enableNotifications)
						.padding(leading: 20)
				)

				Form.Row.Divider()

				Form.Row(
					Label("Excitement Level:").dynamicFont(.system),
					HStack(spacing: 8) {
						Label("😴").font(.title3)
						Slider($excitement, range: 0 ... 10)
							.numberOfTickMarks(11, allowsTickMarkValuesOnly: true)
						Label("🤩").font(.title3)
					}
				)

				Form.Row(
					"Validation percent:",
					HStack(spacing: 4) {
						NumberField(self.$total, numberFormatter: numberFormatter)
							.width(48)
							.verticalCompressionResistancePriority(.required)
						Stepper(range: 0 ... 100, value: 20)
							.bindValue(self.$total)
					}
				)

				Form.Row(
					"Selection:",
					RadioGroup() {
						RadioElement("first")
						RadioElement("second")
						RadioElement("third")
					}
					.bindSelection($radioSelection)
				)

				Form.Row(
					"Rating:",
					HStack {
						LevelIndicator(
							style: .rating,
							value: $ratingValue,
							range: 0.001 ... 5
						)
						.isEditable(true)
						Label($ratingValue.stringValue(using: ratingFormatter))
					}
				)

				Form.Row.Divider()

				Form.Row(
					$labelIsText.transform { "\($0):" },
					TextField($labelIsText)
				)
			}
			.width(400)
		}
		.hugging(h: 1)
		//.showDebugFrames()
	}()
}

//#if DEBUG && canImport(SwiftUI)
//import SwiftUI
//@available(macOS 10.15, *)
//struct FormBuilderPreviews: PreviewProvider {
//	static var previews: some SwiftUI.View {
//		SwiftUI.Group {
//			VStack {
//				FormBuilder().build().body
//				DSFAppKitBuilder.EmptyView()
//			}
//			.SwiftUIPreview()
//		}
//		.padding()
//	}
//}
//#endif
