// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DSFAppKitBuilder",
	 platforms: [
		 .macOS(.v10_11)
	 ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DSFAppKitBuilder",
            targets: ["DSFAppKitBuilder"]),
    ],
    dependencies: [
        // A pager control for the page control
        .package(url: "https://github.com/dagronf/DSFPagerControl", from: "2.0.0"),
		  .package(url: "https://github.com/dagronf/DSFMenuBuilder", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DSFAppKitBuilder",
            dependencies: ["DSFMenuBuilder", "DSFPagerControl"]),
        .testTarget(
            name: "DSFAppKitBuilderTests",
            dependencies: ["DSFAppKitBuilder"]),
    ]
)
