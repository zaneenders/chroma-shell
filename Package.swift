// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "chroma-shell",
    platforms: [
        .macOS("14.0")
    ],
    products: [
        .library(name: "ChromaShell", targets: ["ChromaShell"])
    ],
    dependencies: [
        // .package(path: "../scribe"),
        .package(
            url: "https://github.com/zaneenders/scribe.git",
            branch: "main"),
        .package(
            url: "https://github.com/apple/swift-nio.git",
            from: "2.66.0"),
        /*
        Below are Package dependencies but not for output. Comment out if not
        needed for faster build times.
        */
        .package(
            url: "https://github.com/apple/swift-format.git",
            from: "510.1.0"),
        // View documentation locally with the following command
        // swift package --disable-sandbox preview-documentation --target ChromaShell
        .package(
            url: "https://github.com/apple/swift-docc-plugin.git",
            from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "FileSystem",
            dependencies: [
                "ChromaShell",
                .product(name: "_NIOFileSystem", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings),
        .executableTarget(
            name: "AsyncUpdate",
            dependencies: [
                "ChromaShell"
            ],
            swiftSettings: swiftSettings),
        .executableTarget(
            name: "ShellExample",
            dependencies: [
                "ChromaShell",
                .product(name: "_NIOFileSystem", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings),
        .target(
            name: "ChromaShell",
            dependencies: [.product(name: "ScribeCore", package: "scribe")]),
        .testTarget(
            name: "ChromaShellTests",
            dependencies: [
                "ChromaShell", .product(name: "ScribeCore", package: "scribe"),
            ]),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags([
        "-warn-concurrency", "-enable-actor-data-race-checks",
    ]),
]
