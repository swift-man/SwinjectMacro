import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwinjectMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [Inject.self, InjectOptional.self]
}

// 간단한 오류 타입
struct MacroExpansionErrorMessage: Error, CustomStringConvertible {
  let message: String
  init(_ message: String) { self.message = message }
  var description: String { message }
}

public struct Inject: ExpressionMacro {
  public static func expansion(
      of node: some FreestandingMacroExpansionSyntax,
      in context: some MacroExpansionContext   // <- 제네릭 별칭(Context) 말고, 이렇게!
    ) throws -> ExprSyntax {
    guard let first = node.arguments.first?.expression else {
      throw MacroExpansionErrorMessage("Usage: #Inject(Type.self)")
    }

    // name:, argument: 등 추가 인자를 문자열로 변환
    let pass = node.arguments.dropFirst().map { arg in
      if let label = arg.label?.text, !label.isEmpty {
        return "\(label): \(arg.expression)"
      }
      return "\(arg.expression)"
    }.joined(separator: ", ")

    let extra = pass.isEmpty ? "" : ", \(pass)"
    return ExprSyntax(stringLiteral:
      "Swinject.shared.container.resolve(\(first)\(extra))!"
    )
  }
}

public struct InjectOptional: ExpressionMacro {
  public static func expansion(
      of node: some FreestandingMacroExpansionSyntax,
      in context: some MacroExpansionContext   // <- 제네릭 별칭(Context) 말고, 이렇게!
    ) throws -> ExprSyntax {
    guard let first = node.arguments.first?.expression else {
      throw MacroExpansionErrorMessage("Usage: #InjectOptional(Type.self)")
    }

    let pass = node.arguments.dropFirst().map { arg in
      if let label = arg.label?.text, !label.isEmpty {
        return "\(label): \(arg.expression)"
      }
      return "\(arg.expression)"
    }.joined(separator: ", ")

    let extra = pass.isEmpty ? "" : ", \(pass)"
    return ExprSyntax(stringLiteral:
      "Swinject.shared.container.resolve(\(first)\(extra))"
    )
  }
}
