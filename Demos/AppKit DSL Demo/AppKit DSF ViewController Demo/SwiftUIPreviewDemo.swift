
// A demo of how to us SwiftUI previews to preview DSFAppKitBuilder views :-)

import AppKit
import DSFAppKitBuilder
import DSFValueBinders

@available(macOS 10.15, *)
class DummyTestViewController: DSFAppKitBuilderViewController {
	let radioSelection = ValueBinder<Int>(1)
	override var viewBody: Element {
		VStack(alignment: .centerX) {
			Label("Noodles and fish and chips").font(NSFont.boldSystemFont(ofSize: 16))
			Divider(orientation: .horizontal)
			HStack {
				Label("This is a button ->")
				Button(title: "Press me!") { _ in
					Swift.print("Noodles!")
				}
			}
			Divider(orientation: .horizontal)
			RadioGroup() {
				RadioElement("first")
				RadioElement("second")
				RadioElement("third")
			}
			.bindSelection(self.radioSelection)
			.onChange { which in
				Swift.print("radio is now \(which)")
			}
			Button(title: "Reset") { [weak self] _ in
				self?.radioSelection.wrappedValue = 0
			}
			Divider(orientation: .horizontal)

			EmptyView()
		}
	}
}

/// An 'element' class which is a containerized eleement
class LabelTextFieldPair: Element {
	let label: String
	let textValueBinder: ValueBinder<String>
	init(label: String, value: ValueBinder<String>) {
		self.label = label
		self.textValueBinder = value
	}

	// Override the view() call of the `Element` base class to provide the element's body
	override func view() -> NSView { return self.body.view() }

	lazy var body: Element =
	HStack(distribution: .fillProportionally) {
		Label(self.label)
			.font(NSFont.boldSystemFont(ofSize: NSFont.systemFontSize))
			.alignment(.right)
			.width(100)
		TextField()
			.bindText(updateOnEndEditingOnly: true, self.textValueBinder)
			.horizontalPriorities(hugging: 10, compressionResistance: 10)
	}
}

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
struct DummyPreview: PreviewProvider {
	static var previews: some SwiftUI.View {
		DummyTestViewController().Preview()
	}
}

private let labelContent = ValueBinder("initial value")
private let passwordContent = ValueBinder("initial password")

@available(macOS 10.15, *)
struct LabelTextFieldPairPreview: PreviewProvider {
	static var previews: some SwiftUI.View {
		SwiftUI.Group {
			SwiftUI.VStack {
				LabelTextFieldPair(label: "username", value: labelContent).Preview()
				LabelTextFieldPair(label: "password", value: passwordContent).Preview()
			}
		}
		.padding()
	}
}

#endif
