// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CaptionDecoder",
    products: [
        .library(name: "CaptionDecoder", targets: ["CaptionDecoder"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CaptionDecoder",
            dependencies: ["CaptionDecoderLib", "Commander"]),
        .target(
            name: "CaptionDecoderLib",
            dependencies: ["ByteArrayWrapper"]),
        .target(
            name: "ByteArrayWrapper",
            dependencies: []),
        .testTarget(
            name: "CaptionDecoderTests",
            dependencies: ["CaptionDecoderLib"]),
        .testTarget(
            name: "ByteArrayWrapperTests",
            dependencies: ["ByteArrayWrapper"]),
    ]
)
