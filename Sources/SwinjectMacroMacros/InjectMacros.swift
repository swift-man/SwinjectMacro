import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

// 간단 throw용 Error
struct MacroExpansionError: Error, CustomStringConvertible {
  let message: String
  init(_ message: String) { self.message = message }
  var description: String { message }
}

// (선택) 에디터 진단 메시지
struct SimpleMessage: DiagnosticMessage {
  let message: String
  var diagnosticID: MessageID { .init(domain: "SwinjectMacro", id: "error") }
  var severity: DiagnosticSeverity { .error }
}

extension MacroExpansionContext {
  func error(_ node: some SyntaxProtocol, _ message: String) {
    self.diagnose(Diagnostic(node: Syntax(node), message: SimpleMessage(message: message)))
  }
}

// ---- #Inject(Type.self) → resolve(Type.self)! ----
public struct Inject: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    // SwiftSyntax 5.9: node.argumentList (non-optional)
    guard let first = node.argumentList.first?.expression else {
      context.error(node, "Usage: #Inject(Type.self)")
      throw MacroExpansionError("Usage: #Inject(Type.self)")
    }

    let source = "Swinject.shared.container.resolve(\(first))!"
    return ExprSyntax(stringLiteral: source)
  }
}

// ---- #InjectOptional(Type.self) → resolve(Type.self)? ----
public struct InjectOptional: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    guard let first = node.argumentList.first?.expression else {
      context.error(node, "Usage: #InjectOptional(Type.self)")
      throw MacroExpansionError("Usage: #InjectOptional(Type.self)")
    }

    let source = "Swinject.shared.container.resolve(\(first))"
    return ExprSyntax(stringLiteral: source)
  }
}
