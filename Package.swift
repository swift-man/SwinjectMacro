// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "SwinjectMacro",
  platforms: [.iOS(.v14), .macOS(.v12), .tvOS(.v14), .watchOS(.v7), .macCatalyst(.v14)],
  products: [
    .library(name: "SwinjectMacro", targets: ["SwinjectMacro"]),
    .executable(name: "SwinjectMacroClient", targets: ["SwinjectMacroClient"]),
  ],
  dependencies: [
    // Xcode 15 → 509.x, Xcode 16.x → 600/601.x 자동 선택
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"602.0.0"),
    .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
  ],
  targets: [
    .macro(
      name: "SwinjectMacroMacros",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "SwinjectMacro",
      dependencies: ["SwinjectMacroMacros"]
    ),
    .executableTarget(
      name: "SwinjectMacroClient",
      dependencies: [
        "SwinjectMacro",
        .product(name: "Swinject", package: "Swinject"),
      ]
    )
  ]
)
