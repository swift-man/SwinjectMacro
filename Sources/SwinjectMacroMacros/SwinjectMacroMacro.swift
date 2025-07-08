import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwinjectMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    InjectMacro.self,
  ]
}
