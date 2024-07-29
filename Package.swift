// swift-tools-version: 5.5

import PackageDescription

let package = Package(
	name: "DSFAppKitBuilder",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.library(name: "DSFAppKitBuilder", targets: ["DSFAppKitBuilder"]),
		.library(name: "DSFAppKitBuilder-static", type: .static, targets: ["DSFAppKitBuilder"]),
		.library(name: "DSFAppKitBuilder-shared", type: .dynamic, targets: ["DSFAppKitBuilder"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFPagerControl", from: "2.5.1"),
		.package(url: "https://github.com/dagronf/DSFMenuBuilder", from: "1.2.1"),
		.package(url: "https://github.com/dagronf/DSFValueBinders", from: "0.20.0"),
		.package(url: "https://github.com/dagronf/DSFComboButton", from: "1.0.0"),
		.package(url: "https://github.com/dagronf/DSFToggleButton", from: "7.1.0"),
		.package(url: "https://github.com/dagronf/DSFStepperView", from: "4.3.0"),
		.package(url: "https://github.com/dagronf/DSFSearchField", from: "2.2.2")
	],
	targets: [
		.target(
			name: "DSFAppKitBuilder",
			dependencies: [
				"DSFMenuBuilder",
				"DSFPagerControl",
				"DSFValueBinders",
				"DSFComboButton",
				"DSFToggleButton",
				"DSFStepperView",
				"DSFSearchField"
			]
		),
		.testTarget(
			name: "DSFAppKitBuilderTests",
			dependencies: ["DSFAppKitBuilder"]),
	]
)
