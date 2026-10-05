//
//  InjectionExpansionTests.swift
//  SwinjectMacroTests
//
//  Created by NHN on 2026/10/05.
//  Copyright © 2026 swift-man. All rights reserved.
//

#if canImport(Testing)
import Foundation
import SwiftParser
import SwiftSyntaxMacroExpansion
import SwinjectMacroMacros
import Testing

struct InjectionExpansionTests {
  @Test(arguments: [
    ("#Inject(Service.self)", "Swinject.shared.container.resolve(Service.self)!"),
    ("#InjectOptional(Service.self)", "Swinject.shared.container.resolve(Service.self)"),
    ("#Inject(Service.self, resolver: resolver)", "(resolver).resolve(Service.self)!"),
    ("#InjectOptional(Service.self, resolver: makeResolver())", "(makeResolver()).resolve(Service.self)")
  ])
  func preservesResolutionSource(source: String, expected: String) {
    let context = BasicMacroExpansionContext()
    let expanded = Parser.parse(source: source).expand(
      macros: ["Inject": Inject.self, "InjectOptional": InjectOptional.self],
      in: context
    )

    #expect(expanded.description.trimmingCharacters(in: .whitespacesAndNewlines) == expected)
    #expect(context.diagnostics.isEmpty)
  }

  @Test(arguments: [
    ("#Inject()", "Usage: #Inject(Type.self) or #Inject(Type.self, resolver: resolver)"),
    ("#Inject(Service.self, container: resolver)", "The second argument must use the 'resolver:' label."),
    ("#InjectOptional(Service.self, resolver: resolver, extra: resolver)", "Usage: #InjectOptional(Type.self) or #InjectOptional(Type.self, resolver: resolver)"),
    ("#Inject(type: Service.self)", "Usage: #Inject(Type.self) or #Inject(Type.self, resolver: resolver)")
  ])
  func diagnosesUnsupportedArguments(source: String, expectedMessage: String) {
    let context = BasicMacroExpansionContext()
    _ = Parser.parse(source: source).expand(
      macros: ["Inject": Inject.self, "InjectOptional": InjectOptional.self],
      in: context
    )

    #expect(context.diagnostics.map(\.message) == [expectedMessage])
  }
}
#endif
