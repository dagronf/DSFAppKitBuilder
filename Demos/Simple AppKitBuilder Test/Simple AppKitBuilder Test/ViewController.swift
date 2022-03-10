//
//  ViewController.swift
//  Simple AppKitBuilder Test
//
//  Created by Darren Ford on 1/8/21.
//

import Cocoa
import DSFAppKitBuilder

class ViewController: NSViewController {
	@IBOutlet var primaryView: DSFAppKitBuilderView!

	let identity = AppKitLayoutDemoContainer()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Attack the
		self.primaryView.builder = self.identity // Set our builder as the view's builder
	}
}

class AppKitLayoutDemoContainer: NSObject, DSFAppKitBuilderViewHandler {
	let truncatingText = "This is the description that can be quite long and will be truncated when not enough space is available"
	let wrappingText = "This is the description that can be quite long and will be wrapped when not enough space is available"
	lazy var body: Element =
		ZStack {
			ZLayer(layoutType: .center) {
				VStack {
					IdentityElement(truncatingText, .byTruncatingTail)
					IdentityElement(wrappingText, .byWordWrapping)
				}
			}
		}
}

class IdentityElement: Element {

	let identityDescription: String
	let lineBreakMode: NSLineBreakMode

	init(
		_ description: String,
		_ breakMode: NSLineBreakMode
	) {
		self.identityDescription = description
		self.lineBreakMode = breakMode
	}

	// Override the view() call of the `Element` base class to provide the element's body
	override func view() -> NSView { return self.body.view() }

	lazy var body: Element =
		HStack(spacing: 4) {
			ImageView()
				.image(NSImage(named: "apple_logo_orig")!)             // The image
				.size(width: 42, height: 42, priority: .required)      // fixed size
			VStack(spacing: 2, alignment: .leading) {
				Label("Apple Computer")                                // The label with title 'Name'
					.font(NSFont.systemFont(ofSize: 24))                // Font size 12
					.lineBreakMode(.byTruncatingTail)                   // Truncate line
					.horizontalPriorities(compressionResistance: 100)   // Allow the text field to compress
				Label(identityDescription)                             // The description label
					.font(NSFont.systemFont(ofSize: 12))                // Font size 12
					.textColor(.placeholderTextColor)                   // Grey text
					.lineBreakMode(lineBreakMode)                       // Line break mode
					.horizontalPriorities(compressionResistance: 250)   // Allow the text field to compress
			}
		}
		.edgeInsets(8)
		.border(width: 0.5, color: .textColor)
		.backgroundColor(.quaternaryLabelColor)
		.cornerRadius(4)
}
