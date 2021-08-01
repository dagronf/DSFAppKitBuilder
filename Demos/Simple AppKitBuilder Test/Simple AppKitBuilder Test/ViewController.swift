//
//  ViewController.swift
//  Simple AppKitBuilder Test
//
//  Created by Darren Ford on 1/8/21.
//

import Cocoa
import DSFAppKitBuilder

class ViewController: NSViewController {

	@IBOutlet weak var primaryView: DSFAppKitBuilderView!

	let identity = IdentityContainer()

	override func viewDidLoad() {
		super.viewDidLoad()

		primaryView.builder = self.identity  // Set our builder as the view's builder
	}

}

class IdentityContainer: NSObject, DSFAppKitBuilderViewHandler {
	lazy var body: Element =
		HStack(spacing: 4) {
			ImageView()
				.image(NSImage(named: "apple_logo_orig")!)               // The image
				.size(width: 42, height: 42, priority: .required)        // fixed size
			VStack(spacing: 2, alignment: .leading) {
				Label("Apple Computer")                                  // The label with title 'Name'
					.font(NSFont.systemFont(ofSize: 24))                  // Font size 12
					.lineBreakMode(.byTruncatingTail)                     // Truncate line
					.horizontalPriorities(compressionResistance: 100)     // Allow the text field to compress
				Label("This is the description that can be quite long")  // The label with title 'Description'
					.font(NSFont.systemFont(ofSize: 12))                  // Font size 12
					.textColor(.placeholderTextColor)                     // Grey text
					.lineBreakMode(.byTruncatingTail)                     // Truncate line
					.horizontalPriorities(compressionResistance: 100)     // Allow the text field to compress
			}
		}
}
