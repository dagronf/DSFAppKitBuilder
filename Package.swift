// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFAppKitBuilder",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(name: "DSFAppKitBuilder", type: .static, targets: ["DSFAppKitBuilder"]),
		.library(name: "DSFAppKitBuilder-shared", type: .dynamic, targets: ["DSFAppKitBuilder"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFPagerControl", from: "2.0.0"),
		.package(url: "https://github.com/dagronf/DSFMenuBuilder", from: "1.0.0"),
		.package(url: "https://github.com/dagronf/DSFValueBinders", from: "0.7.1"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "DSFAppKitBuilder",
			dependencies: ["DSFMenuBuilder", "DSFPagerControl", "DSFValueBinders"]),
		.testTarget(
			name: "DSFAppKitBuilderTests",
			dependencies: ["DSFAppKitBuilder"]),
	]
)
