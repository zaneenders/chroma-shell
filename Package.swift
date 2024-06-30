// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "chroma-shell",
    platforms: [
        .macOS("14.0")
    ],
    products: [
        .library(name: "ChromaShell", targets: ["Chroma", "ChromaShell"])
    ],
    dependencies: [
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
        // swift package --disable-sandbox preview-documentation --target Chroma
        .package(
            url: "https://github.com/apple/swift-docc-plugin.git",
            from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "TestChromaClient",
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
            dependencies: ["Chroma"]),
        .target(name: "Chroma"),
        .testTarget(
            name: "ChromaTests",
            dependencies: ["Chroma"]),
        .testTarget(
            name: "ChromaShellTests", dependencies: ["ChromaShell"]),
        .plugin(
            name: "SwiftFormatPlugin",
            capability: .command(
                intent: .custom(
                    verb: "format",
                    description: "format .scribe Swift Packages"),
                permissions: [
                    .writeToPackageDirectory(
                        reason: "This command reformats swift source files")
                ]
            ),
            dependencies: [
                .product(name: "swift-format", package: "swift-format")
            ]
        ),
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
