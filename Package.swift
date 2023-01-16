// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "DSFAppKitBuilder",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(name: "DSFAppKitBuilder", targets: ["DSFAppKitBuilder"]),
		.library(name: "DSFAppKitBuilder-static", type: .static, targets: ["DSFAppKitBuilder"]),
		.library(name: "DSFAppKitBuilder-shared", type: .dynamic, targets: ["DSFAppKitBuilder"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFPagerControl", from: "2.2.0"),
		.package(url: "https://github.com/dagronf/DSFMenuBuilder", from: "1.2.1"),
		.package(url: "https://github.com/dagronf/DSFValueBinders", from: "0.8.3"),
		.package(url: "https://github.com/dagronf/DSFComboButton", from: "0.4.4")
	],
	targets: [
		.target(
			name: "DSFAppKitBuilder",
			dependencies: ["DSFMenuBuilder", "DSFPagerControl", "DSFValueBinders", "DSFComboButton"]),
		.testTarget(
			name: "DSFAppKitBuilderTests",
			dependencies: ["DSFAppKitBuilder"]),
	]
)
