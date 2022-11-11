import Foundation

//MARK: light dependency injection where all dependency'll be saved in containter

protocol IContainer: AnyObject {
    func resolve<T: IResolvable>(args: T.Arguments)->T
    var appState: AppState { get }
}

protocol IResolvable: AnyObject {
    associatedtype Arguments
    
    static var instanceScope: InstanceScope { get }
    
    init(container: IContainer, args: Arguments)
}

enum InstanceScope {
    case singleton
    case perRequest
}

class Container {
    private var singletons: [ObjectIdentifier : AnyObject] = [:]
    
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func makeInstance<T: IResolvable>(args: T.Arguments)->T {
        return T(container: self, args: args)
    }
}

extension Container: IContainer {
    
    func resolve<T>(args: T.Arguments) -> T where T : IResolvable {
        switch T.instanceScope {
        case .perRequest: return makeInstance(args: args)
        case .singleton:
            let key = ObjectIdentifier(T.self)
            if let cached = singletons[key], let instance = cached as? T {
                return instance
            } else {
                let instance: T = makeInstance(args: args)
                singletons[key] = instance
                return instance
            }
        }
    }
    
}

protocol ISingleton: IResolvable where Arguments == Void { }
extension ISingleton {
    static var instanceScope: InstanceScope {
        return .singleton
    }
}

protocol IPerRequest: IResolvable { }
extension IPerRequest {
    static var instanceScope: InstanceScope {
        return .perRequest
    }
}
