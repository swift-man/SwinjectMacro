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

