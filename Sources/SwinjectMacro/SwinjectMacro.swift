// The Swift Programming Language
// https://docs.swift.org/swift-book

import Swinject

@freestanding(expression)
public macro Inject<T>(_ type: T.Type) -> T = #externalMacro(
  module: "SwinjectMacroMacros", type: "Inject"
)

@freestanding(expression)
public macro InjectOptional<T>(_ type: T.Type) -> T? = #externalMacro(
  module: "SwinjectMacroMacros", type: "InjectOptional"
)

/// Resolves a required registration using only the supplied resolver.
@freestanding(expression)
public macro Inject<T>(_ type: T.Type, resolver: any Resolver) -> T = #externalMacro(
  module: "SwinjectMacroMacros", type: "Inject"
)

/// Returns nil when the supplied resolver does not contain a registration.
@freestanding(expression)
public macro InjectOptional<T>(_ type: T.Type, resolver: any Resolver) -> T? = #externalMacro(
  module: "SwinjectMacroMacros", type: "InjectOptional"
)
