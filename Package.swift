// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Strada",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Strada",
            targets: ["Strada"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Strada",
            dependencies: [],
            path: "Source",
            exclude: ["Info.plist", "PathLoaderXcode.swift"],
            resources: [
                .copy("strada.js")
            ])
    ]
)
