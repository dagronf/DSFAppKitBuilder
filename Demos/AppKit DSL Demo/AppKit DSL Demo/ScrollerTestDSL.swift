//
//  SecondaryDSL.swift
//  SecondaryDSL
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit

import DSFAppKitBuilder

class ScrollerTestDSL: NSObject, DSFAppKitBuilderViewHandler {
	lazy var body: Element =
		ScrollView(fitHorizontally: true) {
			VStack(alignment: .leading) {
				Label("Got here!")
				Radio {
					RadioElement("simply dummy text of the printing")
					RadioElement("centuries, but also the leap into electronic")
					RadioElement("sometimes by accident")
					RadioElement("It uses a dictionary of over 200 Latin words")
					RadioElement("many variations of passages")
					RadioElement("making it look like readable English")
					RadioElement("The Extremes of Good and Evil")
					RadioElement("The standard chunk of Lorem Ipsum used since the 1500s")
					RadioElement("that it has a more-or-less normal distribution of letters")
					RadioElement("but also the leap into electronic typesetting")
					RadioElement("reproduced below for those interested")
				}
			}
			.edgeInsets(8)
		}
		.borderType(.lineBorder)
}
