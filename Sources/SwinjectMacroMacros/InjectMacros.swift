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

private func resolutionExpression(
  of node: some FreestandingMacroExpansionSyntax,
  in context: some MacroExpansionContext
) throws -> ExprSyntax {
  let arguments = Array(node.argumentList)
  guard
    arguments.count == 1 || arguments.count == 2,
    let first = arguments.first,
    first.label == nil
  else {
    let message = "Usage: #\(node.macro.text)(Type.self) or #\(node.macro.text)(Type.self, resolver: resolver)"
    context.error(node, message)
    throw MacroExpansionError(message)
  }

  let receiver: ExprSyntax
  if arguments.count == 2 {
    let resolver = arguments[1]
    guard resolver.label?.text == "resolver" else {
      let message = "The second argument must use the 'resolver:' label."
      context.error(resolver, message)
      throw MacroExpansionError(message)
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

    let resolution = try resolutionExpression(of: node, in: context)
    return "\(resolution)!"
  }
}

// ---- #InjectOptional(Type.self) → resolve(Type.self)? ----
public struct InjectOptional: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    try resolutionExpression(of: node, in: context)
  }
}
