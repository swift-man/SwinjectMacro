import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

// throw 용 간단 Error
struct MacroExpansionError: Error, CustomStringConvertible {
  let message: String
  init(_ message: String) { self.message = message }
  var description: String { message }
}

// 에디터에 다이애그 찍을 때
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

// 추가 인자 문자열 구성
private func buildExtraArgs(from args: LabeledExprListSyntax?) -> String {
  guard let args, args.count > 1 else { return "" }
  let tail = args.dropFirst().map { arg in
    if let label = arg.label?.text, !label.isEmpty {
      return "\(label): \(arg.expression)"
    } else {
      return "\(arg.expression)"
    }
  }.joined(separator: ", ")
  return tail.isEmpty ? "" : ", \(tail)"
}

// #Inject(Type.self[, ...]) -> resolve(...)!
public struct Inject: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    guard let first = node.arguments.first?.expression else {
      context.error(node, "Usage: #Inject(Type.self[, ...])")
      throw MacroExpansionError("Usage: #Inject(Type.self[, ...])")
    }

    let extra = buildExtraArgs(from: node.arguments)
    let source = "Swinject.shared.container.resolve(\(first)\(extra))!"
    return ExprSyntax(stringLiteral: source)
  }
}

// #InjectOptional(Type.self[, ...]) -> resolve(...)?  (nil 허용)
public struct InjectOptional: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {

    guard let first = node.arguments.first?.expression else {
      context.error(node, "Usage: #InjectOptional(Type.self[, ...])")
      throw MacroExpansionError("Usage: #InjectOptional(Type.self[, ...])")
    }

    let extra = buildExtraArgs(from: node.arguments)
    let source = "Swinject.shared.container.resolve(\(first)\(extra))"
    return ExprSyntax(stringLiteral: source)
  }
}
