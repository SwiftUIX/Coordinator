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
    public func coordinator<Route, Coordinator: UIViewControllerCoordinator<Route>>(
        _ coordinator: Coordinator
    ) -> some View {
        modifier(AttachUIViewControllerCoordinator(coordinator: coordinator))
    }
    
    public func coordinator<Route, Coordinator: UIWindowCoordinator<Route>>(
        _ coordinator: Coordinator
    ) -> some View {
        modifier(AttachUIWindowCoordinator(coordinator: coordinator))
    }
    
    public func coordinator<Coordinator: ViewCoordinator>(
        _ coordinator: Coordinator
    ) -> some View {
        modifier(AttachViewCoordinator(coordinator: coordinator))
    }
#endif
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
private struct AttachUIViewControllerCoordinator<Route, Coordinator: UIViewControllerCoordinator<Route>>: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    func body(content: Content) -> some View {
        PassthroughView {
            if coordinator.rootViewController == nil {
                ZeroSizeView()
            } else {
                content
                    .environment(coordinator.environmentInsertions)
            }
        }
        .environmentObject(coordinator)
        .environmentObject(AnyViewCoordinator(coordinator))
        .onAppKitOrUIKitViewControllerResolution {
            DispatchQueue.main.async {
                coordinator.rootViewController = $0
            }
        }
    }
}

private struct AttachUIWindowCoordinator<Route, Coordinator: UIWindowCoordinator<Route>>: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    func body(content: Content) -> some View {
        PassthroughView {
            if coordinator.window == nil {
                ZeroSizeView()
            } else {
                content
            }
        }
        .environmentObject(coordinator)
        .environmentObject(AnyViewCoordinator(coordinator))
        .onAppKitOrUIKitViewControllerResolution { viewController in
            DispatchQueue.main.async {
                coordinator.window = viewController.view.window
            }
        }
    }
}

private struct AttachViewCoordinator<Coordinator: ViewCoordinator>: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    func body(content: Content) -> some View {
        PassthroughView {
            content
        }
        .environmentObject(coordinator)
        .environmentObject((coordinator as? AnyViewCoordinator<Coordinator.Route>) ?? AnyViewCoordinator(coordinator))
        .onAppKitOrUIKitViewControllerResolution { viewController in
            DispatchQueue.main.async {
                AnyViewCoordinator(coordinator)._setViewController(viewController)
            }
        }
    }
}
#endif
