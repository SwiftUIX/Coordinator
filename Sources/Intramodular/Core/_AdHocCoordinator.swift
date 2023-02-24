//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
struct _AdHocViewControllerCoordinator<Content: View, Route: Hashable>: AppKitOrUIKitViewControllerRepresentable {
    public typealias AppKitOrUIKitViewControllerType = CocoaHostingController<AnyPresentationView>
    
    let rootView: Content
    let transitionImpl: (Route) -> ViewTransition
    
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType {
        let viewController = CocoaHostingController(
            mainView: AnyPresentationView(
                rootView.environmentObject(AnyViewCoordinator(context.coordinator))
            )
        )
        
        context.coordinator.rootViewController = viewController
        
        return viewController
    }
    
    func updateAppKitOrUIKitViewController(
        _ viewController: AppKitOrUIKitViewControllerType,
        context: Context
    ) {
        context.coordinator.rootViewController = viewController
        context.coordinator.transitionImpl = transitionImpl
    }
    
    final class Coordinator: UIViewControllerCoordinator<Route> {
        var transitionImpl: (Route) -> ViewTransition = { _ in .none }
        
        override func transition(for route: Route) -> ViewTransition {
            transitionImpl(route)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(rootViewController: nil)
    }
}

struct _AdHocWindowCoordinator<Content: View, Route: Hashable>: UIViewControllerRepresentable {
    let rootView: Content
    let transitionImpl: (Route) -> ViewTransition
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = CocoaHostingController(
            mainView: AnyPresentationView(
                rootView.environmentObject(AnyViewCoordinator(context.coordinator))
            )
        )
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.window = uiViewController.view.window
        context.coordinator.transitionImpl = transitionImpl
    }
    
    final class Coordinator: AppKitOrUIKitWindowCoordinator<Route> {
        var transitionImpl: (Route) -> ViewTransition = { _ in .none }
        
        override func transition(for route: Route) -> ViewTransition {
            transitionImpl(route)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(window: nil)
    }
}
#endif

// MARK: - API

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension View {
    public func coordinate<Route: Hashable>(
        _: Route.Type,
        transition: @escaping (Route) -> ViewTransition
    ) -> some View {
        _AdHocViewControllerCoordinator(rootView: self, transitionImpl: transition)
    }
}
#endif
