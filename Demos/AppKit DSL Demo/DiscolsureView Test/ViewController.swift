//
//  ViewController.swift
//  DiscolsureView Test
//
//  Created by Darren Ford on 2/2/2023.
//

import Cocoa
import DSFAppKitBuilder
import DSFMenuBuilder
import DSFValueBinders

extension NumberFormatter {
	convenience init(_ builder: (NumberFormatter) -> Void) {
		self.init()
		builder(self)
	}
}

class ViewController: DSFAppKitBuilderViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	let firstSize = ValueBinder(1.0)
	let firstVisible = ValueBinder(false)
	let firstSizeFormatter = NumberFormatter {
		$0.minimumFractionDigits = 0
		$0.maximumFractionDigits = 1
	}

	override var viewBody: Element {
		VStack {
			Button(title: "Toggle first") { _ in
				self.firstVisible.wrappedValue.toggle()
			}
			ScrollView(borderType: .bezelBorder, fitHorizontally: true) {
				DisclosureGroup {
					DisclosureView(title: "Formatting", isExpandedBinder: firstVisible) {
						Label("First one!")
							.horizontalHuggingPriority(.init(10))
					}
					.disclosureTooltip("Formatting disclosure view")
					
					DisclosureView(title: "Spacing", initiallyExpanded: true) {
						VStack {
							HStack {
								Label("Slidey!")
									.horizontalHuggingPriority(.init(10))
								Slider(range: 0 ... 100, value: 65)
							}
							HStack {
								Label("Activatey?")
									.horizontalHuggingPriority(.init(10))
								Toggle()
							}
						}
					}
				}
				.padding(16)
			}
		}
		.padding(16)

//		VStack(spacing: 8) {
//			DisclosureView(title: "Spacing", initialState: .off, isExpandedBinder: firstVisible) {
//				Grid {
//					GridRow(rowAlignment: .firstBaseline) {
//						PopupButton {
//							MenuItem("Lines")
//							MenuItem("At Least")
//							MenuItem("Exactly")
//							MenuItem("Between")
//						}
//						TextField("one")
//							.isEnabled(false)
//							.bindValue(firstSize, formatter: firstSizeFormatter)
//							.width(40)
//						Stepper(range: 0.1 ... 10.0, increment: 0.1)
//							.valueWraps(false)
//							.bindValue(firstSize)
//					}
//					GridRow(rowAlignment: .firstBaseline) {
//						Label("Before Paragraph")
//							.horizontalHuggingPriority(.defaultLow)
//						TextField("one")
//							.width(40)
//						Stepper()
//					}
//					GridRow(rowAlignment: .firstBaseline) {
//						Label("After Paragraph")
//							.horizontalHuggingPriority(.defaultLow)
//						TextField("one")
//							.width(40)
//						Stepper()
//							.horizontalHuggingPriority(999)
//					}
//				}
//				.columnFormatting(xPlacement: .trailing, atColumn: 1)
//			}
//
//			HDivider()
//			Button(title: "Toggle first")
//				.bindOnOffState(firstVisible)
//
//			DisclosureView(title: "Style") {
//				HStack {
//					Label("Style style!")
//						.horizontalHuggingPriority(.init(10))
//					Toggle()
//				}
//			}
//
//			HDivider()
//
//			EmptyView()
//		}
//		.padding(20)
	}


}

