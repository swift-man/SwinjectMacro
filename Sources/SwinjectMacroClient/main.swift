//
//  main.swift
//  SwinjectMacro
//
//  Created by NHN on 7/8/25.
//

import SwinjectMacro

protocol A {

}

@Inject
var a: A

print("a : \(a)")
