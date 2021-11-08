// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "db_data_generator",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
         .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
         .package(url: "https://github.com/vapor/postgres-kit", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "db_data_generator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PostgresKit", package: "postgres-kit"),
            ]),
    ]
)
