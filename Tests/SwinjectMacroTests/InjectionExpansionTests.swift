//
//  InjectionExpansionTests.swift
//  SwinjectMacroTests
//
//  Created by NHN on 2026/10/05.
//  Copyright © 2026 swift-man. All rights reserved.
//

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
    "#Inject()",
    "#Inject(Service.self, container: resolver)",
    "#InjectOptional(Service.self, resolver: resolver, extra: resolver)",
    "#Inject(type: Service.self)"
  ])
  func diagnosesUnsupportedArguments(source: String) {
    let context = BasicMacroExpansionContext()
    _ = Parser.parse(source: source).expand(
      macros: ["Inject": Inject.self, "InjectOptional": InjectOptional.self],
      in: context
    )

    #expect(!context.diagnostics.isEmpty)
  }
}
