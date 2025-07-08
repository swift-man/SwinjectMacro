import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct InjectMacro: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    guard let varDecl = declaration.as(VariableDeclSyntax.self),
          let binding = varDecl.bindings.first,
          let typeAnnotation = binding.typeAnnotation?.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
    else {
      fatalError("Missing type info in @Inject property")
    }

    let code = """
        get {
            Swinject.shared.container.resolve(\(typeAnnotation).self)!
        }
        """

    return [AccessorDeclSyntax("\(raw: code)")]
  }
}

@main
struct SwinjectMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    InjectMacro.self,
  ]
}
