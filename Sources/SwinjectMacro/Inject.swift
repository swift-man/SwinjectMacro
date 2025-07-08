//
//  Inject.swift
//  SwinjectMacro
//
//  Created by NHN on 7/8/25.
//

@attached(accessor)
public macro Inject() = #externalMacro(module: "SwinjectMacroMacros", type: "InjectMacro")
