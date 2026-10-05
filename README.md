# SwinjectMacro

## Explicit Resolver

Use the resolver supplied by your composition root or Assembly factory. These overloads do not reference a global container:

```swift
import Swinject
import SwinjectMacro

let container = Container()
container.register(Service.self) { _ in Service() }

let service = #Inject(Service.self, resolver: container)
let optionalService = #InjectOptional(Service.self, resolver: container)

container.register(Feature.self) { resolver in
  Feature(service: #Inject(Service.self, resolver: resolver))
}
```

The argument accepts any Swinject `Resolver`, including the resolver passed into `Container.register` closures. Resolver expressions are evaluated once. Registration and object scope remain Swinject responsibilities; these macros do not register dependencies or change their lifetimes.

`#Inject` force-unwraps the resolved value and traps when a required registration is missing. Use `#InjectOptional` with your own `guard` and diagnostic when failure must be handled explicitly. Independent containers do not fall back to another container.

## Legacy Global Lookup

The one-argument overloads remain source-compatible. They expand to `Swinject.shared.container.resolve(...)` and require the consumer to provide that global accessor. Limit this form to an existing composition boundary; prefer explicit resolvers and initializer injection for new code.

```swift
import SwinjectMacro
import Swinject

struct Service {
  var val = "a"
}

final class Swinject {
  static let shared = Swinject()
  
  let container = Container()
}

func example() {
  Swinject.shared.container.register(Service.self) { _ in
    Service()
  }
  
  let s: Service = #Inject(Service.self)
  var maybe: Service? = #InjectOptional(Service.self)
}
```

## Validation

Run `swift test` with a Swift 6 or later toolchain for the Swift Testing suite. It checks independent containers, optional misses, Assembly factory resolution, single evaluation, object scope, legacy expansion compatibility, and invalid argument diagnostics. The package keeps its existing Swift tools 5.9 manifest and SwiftSyntax 509.x dependency. Test sources are guarded by `canImport(Testing)` so older toolchains can compile the test target without Swift Testing, but no assertions run there. An empty test target is not evidence of passing tests; verification requires Swift 6 or later.
