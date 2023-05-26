//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension View {
    public func coordinator<Route, Coordinator: UIViewControllerCoordinator<Route>>(
        _ coordinator: Coordinator,
        onConnect: @escaping () -> Void = { }
    ) -> some View {
        modifier(
            AttachUIViewControllerCoordinator(
                coordinator: coordinator,
                onConnect: onConnect
            )
        )
    }
    
    public func coordinator<Route, Coordinator: AppKitOrUIKitWindowCoordinator<Route>>(
        _ coordinator: Coordinator,
        onConnect: @escaping () -> Void = { }
    ) -> some View {
        modifier(
            AttachAppKitOrUIKitWindowCoordinator(
                coordinator: coordinator,
                onConnect: onConnect
            )
        )
    }
    
    public func coordinator<Coordinator: ViewCoordinator>(
        _ coordinator: Coordinator,
        onConnect: @escaping () -> Void = { }
    ) -> some View {
        modifier(
            AttachViewCoordinator(
                coordinator: coordinator,
                onConnect: onConnect
            )
        )
    }
}
#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
private struct AttachUIViewControllerCoordinator<Route, Coordinator: UIViewControllerCoordinator<Route>>: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    let onConnect: () -> Void
    
    func body(content: Content) -> some View {
        PassthroughView {
            if coordinator.rootViewController == nil {
                ZeroSizeView()
            } else {
                content.environment(coordinator.environmentInsertions)
            }
        }
        .environmentObject(coordinator)
        .environmentObject(AnyViewCoordinator(coordinator))
        .onAppKitOrUIKitViewControllerResolution { viewController in
            DispatchQueue.main.async {
                coordinator.rootViewController = viewController
                
                onConnect()
            }
        }
    }
}

private struct AttachAppKitOrUIKitWindowCoordinator<Route, Coordinator: AppKitOrUIKitWindowCoordinator<Route>>: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    let onConnect: () -> Void

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
                
                onConnect()
            }
        }
    }
}

private struct AttachViewCoordinator<Coordinator: ViewCoordinator>: ViewModifier {
    @ObservedObject var coordinator: Coordinator
    
    let onConnect: () -> Void

    func body(content: Content) -> some View {
        PassthroughView {
            content
        }
        .environmentObject(coordinator)
        .environmentObject((coordinator as? AnyViewCoordinator<Coordinator.Route>) ?? AnyViewCoordinator(coordinator))
        .onAppKitOrUIKitViewControllerResolution { viewController in
            DispatchQueue.main.async {
                AnyViewCoordinator(coordinator)._setViewController(viewController)
                
                onConnect()
            }
        }
    }
}
#endif
