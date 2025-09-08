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

  maybe?.val = "c"
  print("s : \(s.val)")
  print("maybe : \(String(describing: maybe?.val))")
  // 태그/인자도 그대로 전달 가능
  // let premium: Service = #Inject(Service.self, name: "premium")
}

