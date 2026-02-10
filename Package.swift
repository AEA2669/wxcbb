// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevBrowser",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "DevBrowser",
            targets: ["DevBrowser"])
    ],
    targets: [
        .target(
            name: "DevBrowser",
            path: "Sources")
    ]
)
