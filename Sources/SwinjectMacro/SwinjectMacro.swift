// The Swift Programming Language
// https://docs.swift.org/swift-book

@freestanding(expression)
public macro Inject<T>(_ type: T.Type) -> T = #externalMacro(
  module: "SwinjectMacroMacros", type: "Inject"
)

@freestanding(expression)
public macro InjectOptional<T>(_ type: T.Type) -> T? = #externalMacro(
  module: "SwinjectMacroMacros", type: "InjectOptional"
)
