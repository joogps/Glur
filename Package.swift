// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Glur",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Glur",
            targets: ["Glur"]),
        // Opt-in: blurs the content behind a view, using a private API on iOS. See the README.
        .library(
            name: "GlurBackdrop",
            targets: ["GlurBackdrop"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Glur",
            resources: [.process("Resources")]
        ),
        .target(
            name: "GlurBackdrop",
            dependencies: ["Glur"]
        ),
    ]
)
