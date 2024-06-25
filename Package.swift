// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "chroma-shell",
    products: [
        .library(
            name: "Chroma",
            targets: ["Chroma"])
    ],
    dependencies: [
        // Used for Generating documentation
        /*
        swift package --allow-writing-to-directory ./gh-pages/docs \
        generate-documentation --target Chroma \
        --output-path ./gh-pages/docs \
        --disable-indexing \
        --transform-for-static-hosting \
        --include-extended-types \
        --hosting-base-path chroma-shell
        */
        // For Viewing docs locally
        // swift package --disable-sandbox preview-documentation --target Chroma --include-extended-types
        .package(
            url: "https://github.com/apple/swift-docc-plugin",
            from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Chroma"),
        .testTarget(
            name: "ChromaTests",
            dependencies: ["Chroma"]),
    ]
)
