//
//  BoxDSL.swift
//  BoxDSL
//
//  Created by Darren Ford on 30/7/21.
//

import AppKit
import DSFAppKitBuilder

class BoxDSL: NSObject, DSFAppKitBuilderViewHandler {

	lazy var body: Element =
	VStack(spacing: 12) {
		HStack(spacing: 20) {
			Box("Fishy 1") {
				VStack {
					Label("This is test")
						.horizontalPriorities(hugging: 100)
					TextField()
						.placeholderText("Noodles")
						.horizontalPriorities(hugging: 100)
					EmptyView()
						.verticalPriorities(hugging: 100, compressionResistance: 100)
						.horizontalPriorities(hugging: 100, compressionResistance: 100)
				}
				.edgeInsets(8)
				.hugging(h: 10)
			}
			.verticalPriorities(hugging: 100)
			.horizontalPriorities(hugging: 100)
			Box("Fishy 12") {
				VStack {
					Label("This is test")
						.horizontalPriorities(hugging: 10)
					TextField()
						.placeholderText("Noodles")
						.horizontalPriorities(hugging: 10)
					Segmented {
						Segment("12-1")
						Segment("12-2")
						Segment("12-3")
					}
					.selectSegment(0)
					EmptyView()
						.verticalPriorities(hugging: 10, compressionResistance: 10)
						.horizontalPriorities(hugging: 10, compressionResistance: 10)
				}
				.edgeInsets(8)
				.hugging(h: 10)
			}
			.verticalPriorities(hugging: 100)
			.horizontalPriorities(hugging: 100)
		}
		.distribution(.fillEqually)

		HStack(spacing: 20) {

			Box("Fishy 21") {
				VStack {
					Label("This is test")
						.horizontalPriorities(hugging: 10)
					TextField()
						.placeholderText("Noodles")
						.horizontalPriorities(hugging: 10)
					Segmented {
						Segment("21-1")
						Segment("21-2")
						Segment("21-3")
					}
					.selectSegment(2)
					EmptyView()
						.verticalPriorities(hugging: 10, compressionResistance: 10)
						.horizontalPriorities(hugging: 10, compressionResistance: 10)
				}
				.edgeInsets(8)
				.hugging(h: 10)
			}
			.verticalPriorities(hugging: 100)
			.horizontalPriorities(hugging: 100)

			Box("Fishy 21") {
				VStack {
					Label("This is test")
						.horizontalPriorities(hugging: 10)
					TextField()
						.placeholderText("Noodles")
						.horizontalPriorities(hugging: 10)
					EmptyView()
						.verticalPriorities(hugging: 10, compressionResistance: 10)
						.horizontalPriorities(hugging: 10, compressionResistance: 10)
				}
				.edgeInsets(8)
				.hugging(h: 10)
			}
			.verticalPriorities(hugging: 100)
			.horizontalPriorities(hugging: 100)
		}
		.distribution(.fillEqually)
	}
	.distribution(.fillEqually)
}



/*

 var body: Element =
 VStack {
	 HStack(distribution: .fillEqually) {
		 Label("Name").alignment(.right).horizontalPriorities(hugging: 10)
		 TextField().alignment(.left).horizontalPriorities(hugging: 10)
	 }
	 HStack(distribution: .fillEqually) {
		 Label("Username").alignment(.right).horizontalPriorities(hugging: 10)
		 TextField().alignment(.left).horizontalPriorities(hugging: 10)
	 }
	 HStack(distribution: .fillEqually) {
		 Label("Subscription Type").alignment(.right).horizontalPriorities(hugging: 10)
		 PopupButton {
			 MenuItem(title: "Weekly")
			 MenuItem(title: "Monthly")
			 MenuItem(title: "Yearly")
		 }
	 }
 }

 */
