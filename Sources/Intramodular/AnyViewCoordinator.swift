//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

protocol _opaque_AnyViewCoordinator {
    #if os(iOS)
    func _setViewController(_ viewController: AppKitOrUIKitViewController)
    #endif
}

public final class AnyViewCoordinator<Route: Hashable>: _opaque_AnyViewCoordinator, ViewCoordinator {
    public let base: EnvironmentProvider
    
    public var environmentBuilder: EnvironmentBuilder {
        get {
            base.environmentBuilder
        } set {
            base.environmentBuilder = newValue
        }
    }
    
    private let transitionImpl: (Route) -> ViewTransition
    private let triggerPublisherImpl: (Route) -> AnyPublisher<ViewTransitionContext, Error>
    private let triggerImpl: (Route) -> AnyPublisher<ViewTransitionContext, Error>
    
    public init<VC: ViewCoordinator>(_ coordinator: VC) where VC.Route == Route {
        self.base = coordinator
        
        self.transitionImpl = coordinator.transition
        self.triggerPublisherImpl = coordinator.triggerPublisher
        self.triggerImpl = coordinator.trigger
    }
    
    public func transition(for route: Route) -> Transition {
        transitionImpl(route)
    }
    
    @discardableResult
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        triggerPublisherImpl(route)
    }
    
    @discardableResult
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        triggerImpl(route)
    }

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    func _setViewController(_ viewController: AppKitOrUIKitViewController) {
        if let base = base as? _opaque_UIViewControllerCoordinator {
            if base.rootViewController == nil {
                base.rootViewController = viewController
            }
        } else if let base = base as? _opaque_UIWindowCoordinator {
            if base.window == nil {
                base.window = viewController.view.window
            }
        } else if let base = base as? _opaque_AnyViewCoordinator {
            base._setViewController(viewController)
        }
    }
    #endif
}
