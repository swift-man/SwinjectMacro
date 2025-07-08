//
//  main.swift
//  SwinjectMacro
//
//  Created by NHN on 7/8/25.
//

import SwinjectMacro
import Swinject

public final class Swinject {
  @MainActor public static let shared = Swinject()
  public let container = Container()
}

protocol P {

}

class A: P {
  init() {
    print("A init")
  }
}

Swinject.shared.container.register(P.self) { _ in
  A()
}

@Inject
var a: P

print("a : \(a)")
