// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NanoIDBenchmarks",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(name: "NanoID", path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "NanoIDBenchmarks",
            dependencies: [
                .product(name: "NanoID", package: "NanoID"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "NanoIDBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
