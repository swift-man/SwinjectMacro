//
//  Plugin.swift
//  SwinjectMacro
//
//  Created by NHN on 9/9/25.
//

#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros 

@main
struct SwinjectMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    Inject.self,
    InjectOptional.self
  ]
}
#endif
