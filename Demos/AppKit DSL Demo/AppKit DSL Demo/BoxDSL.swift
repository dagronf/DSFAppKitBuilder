//
//  BoxDSL.swift
//  BoxDSL
//
//  Created by Darren Ford on 30/7/21.
//

import AppKit
import DSFAppKitBuilder

class BoxDSL: NSObject, DSFAppKitBuilderViewHandler {
	var body: Element =
	VStack {
		HStack {
			Box("Fishy 1") {
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

		HStack {

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

