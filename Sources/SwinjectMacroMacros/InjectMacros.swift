import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

struct MacroExpansionError: Error, CustomStringConvertible {
  let message: String
  init(_ message: String) { self.message = message }
  var description: String { message }
}

public struct Inject: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    // Type.self 하나만 허용
    guard let first = node.arguments.first?.expression else {
      // 위치 검사는 제거했으므로, 사용법만 안내
      #if canImport(SwiftDiagnostics)
      context.diagnose(
        Diagnostic(
          node: Syntax(node),
          message: SimpleMessage(message: "Usage: #Inject(Type.self)")
        )
      )
      #endif
      throw MacroExpansionError("Usage: #Inject(Type.self)")
    }

    // 파라미터 없이 강제 언래핑 버전
    let source = "Swinject.shared.container.resolve(\(first))!"
    return ExprSyntax(stringLiteral: source)
  }
}

public struct InjectOptional: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    guard let first = node.arguments.first?.expression else {
      #if canImport(SwiftDiagnostics)
      context.diagnose(
        Diagnostic(
          node: Syntax(node),
          message: SimpleMessage(message: "Usage: #InjectOptional(Type.self)")
        )
      )
      #endif
      throw MacroExpansionError("Usage: #InjectOptional(Type.self)")
    }

    // 파라미터 없이 옵셔널 버전
    let source = "Swinject.shared.container.resolve(\(first))"
    return ExprSyntax(stringLiteral: source)
  }
}

// 에디터 진단용(선택)
struct SimpleMessage: DiagnosticMessage {
  let message: String
  var diagnosticID: MessageID { .init(domain: "SwinjectMacro", id: "error") }
  var severity: DiagnosticSeverity { .error }
}
