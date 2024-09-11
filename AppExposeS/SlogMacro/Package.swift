// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SlogMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SlogMacro",
            targets: ["SlogMacro"]
        ),
        .executable(
            name: "SlogMacroClient",
            targets: ["SlogMacroClient"]
        ),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "SlogMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
//        .target(name: "SlogMacro", dependencies: ["SlogMacroMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "SlogMacroClient", dependencies: ["SlogMacro"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "SlogMacroTests",
            dependencies: [
                "SlogMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
