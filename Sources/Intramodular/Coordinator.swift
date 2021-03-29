//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

@propertyWrapper
public struct Coordinator<WrappedValue: ViewCoordinator>: DynamicProperty, PropertyWrapper {
    @Environment(\.environmentBuilder) var environmentBuilder
    
    @OptionalEnvironmentObject public var _wrappedValue0: WrappedValue?
    @OptionalEnvironmentObject public var _wrappedValue1: AnyViewCoordinator<WrappedValue.Route>?
    
    @inline(never)
    public var wrappedValue: WrappedValue {
        let result: Any? = nil
            ?? _wrappedValue0
            ?? _wrappedValue1?.base
            ?? OpaqueBaseViewCoordinator
            ._runtimeLookup[ObjectIdentifier(WrappedValue.self)]!
            .takeUnretainedValue()
        
        if let result = result as? EnvironmentProvider {
            result.environmentBuilder.merge(environmentBuilder)
        }
        
        return result as! WrappedValue
    }
    
    public init() {
        
    }
    
    public init<Route: Hashable>(
        _: Route.Type
    ) where WrappedValue == AnyViewCoordinator<Route> {
        
    }
}

extension View {
    public func coordinator<C: ViewCoordinator>(_ coordinator: C) -> some View {
        environmentObject(coordinator)
    }
}
