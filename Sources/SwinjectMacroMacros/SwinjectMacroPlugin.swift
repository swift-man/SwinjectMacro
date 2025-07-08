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

public struct InjectFunctionMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let genericArgs = node.genericArgumentClause?.arguments,
          let typeExpr = genericArgs.first?.argument else {
      fatalError("Inject<T>() must have a generic argument")
    }

    return "Swinject.shared.container.resolve(\(typeExpr).self)!" // ExprSyntax
  }
}

@main
struct SwinjectMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    InjectMacro.self,
    InjectFunctionMacro.self,
  ]
}
