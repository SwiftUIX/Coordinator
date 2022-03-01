//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

@propertyWrapper
public struct Coordinator<WrappedValue: ViewCoordinator>: DynamicProperty, PropertyWrapper {
    @Environment(\._environmentInsertions) var environmentInsertions
    
    @OptionalEnvironmentObject public var _wrappedValue0: WrappedValue?
    @OptionalEnvironmentObject public var _wrappedValue1: AnyViewCoordinator<WrappedValue.Route>?
    
    @inline(never)
    public var wrappedValue: WrappedValue {
        let result: Any? = nil
            ?? _wrappedValue0
            ?? _wrappedValue1?.base
            ?? OpaqueBaseViewCoordinator
            ._runtimeLookup[ObjectIdentifier(WrappedValue.self)]?.takeUnretainedValue()
        
        guard let result = result else {
            fatalError("Could not resolve a coordinator for \(String(describing: WrappedValue.Route.self)) in the view hierarchy. Try adding `.coordinator(myCoordinator)` in your view hierarchy.")
        }
        
        if let result = result as? EnvironmentPropagator {
            result.environmentInsertions.merge(environmentInsertions)
        }
        
        return result as! WrappedValue
    }
    
    public init() {
        
    }
    
    public init<Route>(for route: Route.Type) where WrappedValue == AnyViewCoordinator<Route> {
        
    }
    
    public init<Route>(
        _ route: Route.Type
    ) where WrappedValue == AnyViewCoordinator<Route> {
        
    }
}

extension View {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    public func coordinator<C: UIViewControllerCoordinator<Route>, Route>(
        _ coordinator: C
    ) -> some View {
        environmentObject(coordinator)
            .environmentObject(AnyViewCoordinator(coordinator))
            .onAppKitOrUIKitViewControllerResolution {
                if coordinator.rootViewController == nil {
                    coordinator.rootViewController = $0
                }
            }
        
    }
    
    public func coordinator<C: UIWindowCoordinator<Route>, Route>(
        _ coordinator: C
    ) -> some View {
        environmentObject(coordinator)
            .environmentObject(AnyViewCoordinator(coordinator))
            .onAppKitOrUIKitViewControllerResolution {
                if coordinator.window == nil {
                    coordinator.window = $0.view.window
                }
            }
    }
    
    public func coordinator<C: ViewCoordinator>(
        _ coordinator: C
    ) -> some View {
        environmentObject(coordinator)
            .environmentObject((coordinator as? AnyViewCoordinator<C.Route>) ?? AnyViewCoordinator(coordinator))
            .onAppKitOrUIKitViewControllerResolution {
                AnyViewCoordinator(coordinator)._setViewController($0)
            }
    }
    #endif
}
