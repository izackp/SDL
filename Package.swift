// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SDL2Swift",
    products: [
        .library(
            name: "SDL2Swift",
            targets: ["SDL2Swift"]),
        .executable(
            name: "SDLDemo",
            targets: ["SDLDemo"]),
        ],
    targets: [
        .target(
            name: "SDLDemo",
            dependencies: ["SDL2Swift"]),
        .target(
            name: "SDL2Swift",
            dependencies: ["SDL2"]),
        .systemLibrary(
            name: "SDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
                .apt(["libsdl2-dev"])
            ]),
        .testTarget(
            name: "SDLTests",
            dependencies: ["SDL2Swift"]),
        ],
    swiftLanguageVersions: [.v5]
)
