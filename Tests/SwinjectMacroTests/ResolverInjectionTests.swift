//
//  ResolverInjectionTests.swift
//  SwinjectMacroTests
//
//  Created by NHN on 2026/10/05.
//  Copyright © 2026 swift-man. All rights reserved.
//

#if canImport(Testing)
import Foundation
import Swinject
import SwinjectMacro
import Testing

private protocol Service {
  var value: String { get }
}

private struct ServiceImplementation: Service {
  let value: String
}

struct ResolverInjectionTests {
  @Test
  func resolvesFromIndependentContainers() {
    let firstContainer = Container()
    let secondContainer = Container()
    firstContainer.register(Service.self) { _ in ServiceImplementation(value: "first") }
    secondContainer.register(Service.self) { _ in ServiceImplementation(value: "second") }

    let first = #Inject(Service.self, resolver: firstContainer)
    let second = #Inject(Service.self, resolver: secondContainer)

    #expect(first.value == "first")
    #expect(second.value == "second")
  }

  @Test
  func returnsNilForMissingRegistration() {
    let registeredContainer = Container()
    registeredContainer.register(Service.self) { _ in ServiceImplementation(value: "registered") }
    let emptyContainer = Container()

    let service = #InjectOptional(Service.self, resolver: emptyContainer)

    #expect(service == nil)
    #expect(#InjectOptional(Service.self, resolver: registeredContainer)?.value == "registered")
  }

  @Test
  func usesAssemblyFactoryResolver() {
    let container = Container()
    container.register(Service.self) { _ in ServiceImplementation(value: "assembly") }
    container.register(String.self) { resolver in
      #Inject(Service.self, resolver: resolver).value
    }

    #expect(container.resolve(String.self) == "assembly")
  }

  @Test
  func evaluatesResolverExpressionOnce() {
    let container = Container()
    container.register(Service.self) { _ in ServiceImplementation(value: "once") }
    var evaluationCount = 0
    func makeResolver() -> any Resolver {
      evaluationCount += 1
      return container
    }

    let service = #Inject(Service.self, resolver: makeResolver())

    #expect(service.value == "once")
    #expect(evaluationCount == 1)
  }

  @Test
  func preservesContainerObjectScope() {
    let container = Container()
    container.register(NSObject.self) { _ in NSObject() }.inObjectScope(.container)

    let first = #Inject(NSObject.self, resolver: container)
    let second = #Inject(NSObject.self, resolver: container)

    #expect(first === second)
  }
}
#endif
