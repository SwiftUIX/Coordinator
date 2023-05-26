//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

/// A property wrapper that provides access to a view coordinator.
@propertyWrapper
public struct Coordinator<WrappedValue: ViewCoordinator>: DynamicProperty, PropertyWrapper {
    @Environment(\._environmentInsertions) var environmentInsertions
    
    @EnvironmentObject.Optional public var _wrappedValue0: WrappedValue?
    @EnvironmentObject.Optional public var _wrappedValue1: AnyViewCoordinator<WrappedValue.Route>?
    
    @inline(never)
    public var wrappedValue: WrappedValue {
        let result: Any? = nil
            ?? _wrappedValue0
            ?? _wrappedValue1?.base
            ?? _coordinatorRuntimeLookup[ObjectIdentifier(WrappedValue.self)]?.takeUnretainedValue()
        
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
