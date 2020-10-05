//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _AdHocCoordinator<Content: View, Route: Hashable>: UIViewControllerRepresentable {
    @Environment(\._appKitOrUIKitViewController) var _appKitOrUIKitViewController
    
    let rootView: Content
    let transitionImpl: (Route) -> ViewTransition
    
    func makeUIViewController(context: Context) -> some UIViewController {
        context.coordinator.rootViewController =         context.environment._appKitOrUIKitViewController
        
        return UIHostingController(
            rootView: rootView
                .environmentObject(AnyViewCoordinator(context.coordinator))
        )
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
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

extension View {
    public func coordinate<Route: Hashable>(
        _: Route.Type,
        transition: @escaping (Route) -> ViewTransition
    ) -> some View {
        _AdHocCoordinator(rootView: self, transitionImpl: transition)
    }
}

#endif
