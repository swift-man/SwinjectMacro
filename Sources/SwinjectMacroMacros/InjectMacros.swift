import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

// (선택) 에디터 진단 메시지
struct SimpleMessage: DiagnosticMessage {
  let message: String
  var diagnosticID: MessageID { .init(domain: "SwinjectMacro", id: "error") }
  var severity: DiagnosticSeverity { .error }
}

private func resolutionExpression(
  of node: some FreestandingMacroExpansionSyntax
) throws -> ExprSyntax {
  let arguments = Array(node.argumentList)
  guard
    arguments.count == 1 || arguments.count == 2,
    let first = arguments.first,
    first.label == nil
  else {
    let message = "Usage: #\(node.macro.text)(Type.self) or #\(node.macro.text)(Type.self, resolver: resolver)"
    throw DiagnosticsError(diagnostics: [
      Diagnostic(node: Syntax(node), message: SimpleMessage(message: message))
    ])
  }

  let receiver: ExprSyntax
  if arguments.count == 2 {
    let resolver = arguments[1]
    guard resolver.label?.text == "resolver" else {
      let message = "The second argument must use the 'resolver:' label."
      throw DiagnosticsError(diagnostics: [
        Diagnostic(node: Syntax(resolver), message: SimpleMessage(message: message))
      ])
    }
    receiver = "(\(resolver.expression))"
  } else {
    receiver = "Swinject.shared.container"
  }
  return "\(receiver).resolve(\(first.expression))"
}

public struct Inject: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    let resolution = try resolutionExpression(of: node)
    return "\(resolution)!"
  }
}

public struct InjectOptional: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    try resolutionExpression(of: node)
  }
}
