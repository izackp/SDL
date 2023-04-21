// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SDL2Swift",
    products: [
        .library(
            name: "SDL2Swift",
            targets: ["SDL2Swift"]),
        .library(
            name: "SDL2_TTFSwift",
            targets: ["SDL2_TTFSwift"]),
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
        .target(
            name: "SDL2_TTFSwift",
            dependencies: ["SDL2Swift", "SDL2_TTF"]),
        .systemLibrary(
            name: "SDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
                .apt(["libsdl2-dev"])
            ]),
        .systemLibrary(
            name: "SDL2_Image",
            pkgConfig: "sdl2_image",
            providers: [
              .brew(["sdl2_image"]),
              .apt(["libsdl2_image-dev"]) ]
        ),
        .systemLibrary(
            name: "SDL2_Mixer",
            pkgConfig: "sdl2_mixer",
            providers: [
              .brew(["sdl2_mixer"]),
              .apt(["libsdl2_mixer-dev"]) ]
        ),
        .systemLibrary(
            name: "SDL2_TTF",
            pkgConfig: "sdl2_ttf",
            providers: [
              .brew(["sdl2_ttf"]),
              .apt(["libsdl2_ttf-dev"]) ]
        ),
        .testTarget(
            name: "SDLTests",
            dependencies: ["SDL2Swift"]),
        ],
    swiftLanguageVersions: [.v5]
)
