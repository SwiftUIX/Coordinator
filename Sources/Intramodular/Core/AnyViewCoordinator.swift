//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

protocol _opaque_AnyViewCoordinator {
    #if os(iOS) || os(macOS) || os(tvOS)
    func _setViewController(_ viewController: AppKitOrUIKitViewController)
    #endif
}

public final class AnyViewCoordinator<Route>: _opaque_AnyViewCoordinator, ViewCoordinator {
    public let base: EnvironmentPropagator
    
    public var environmentInsertions: EnvironmentInsertions {
        get {
            base.environmentInsertions
        } set {
            base.environmentInsertions = newValue
        }
    }
    
    private let transitionImpl: (Route) -> ViewTransition
    private let triggerPublisherImpl: (Route, Bool) -> AnyPublisher<ViewTransitionContext, Error>
    private let triggerImpl: @MainActor (Route, Bool) -> AnyPublisher<ViewTransitionContext, Error>
    
    public init<VC: ViewCoordinator>(
        _ coordinator: VC
    ) where VC.Route == Route {
        self.base = coordinator
        
        self.transitionImpl = coordinator.transition
        self.triggerPublisherImpl = coordinator.triggerPublisher
        self.triggerImpl = coordinator.trigger
    }
    
    public func transition(for route: Route) -> ViewTransition {
        transitionImpl(route)
    }
    
    @discardableResult
    public func triggerPublisher(for route: Route, animated: Bool = true) -> AnyPublisher<ViewTransitionContext, Error> {
        triggerPublisherImpl(route, animated)
    }
    
    @discardableResult
    @MainActor
    public func trigger(_ route: Route, animated: Bool = true) -> AnyPublisher<ViewTransitionContext, Error> {
        triggerImpl(route, animated)
    }

    #if os(iOS) || os(macOS) || os(tvOS)
    @MainActor
    func _setViewController(_ viewController: AppKitOrUIKitViewController) {
        #if os(iOS) || os(tvOS)
        if let base = base as? any AppKitOrUIKitViewControllerCoordinatorType {
            if base.rootViewController == nil {
                base.rootViewController = viewController
            }
        } else if let base = base as? any AppKitOrUIKitWindowCoordinatorType {
            if base.window == nil {
                base.window = viewController.view.window
            }
        } else if let base = base as? _opaque_AnyViewCoordinator {
            base._setViewController(viewController)
        }
        #else
        fatalError("unimplemented")
        #endif
    }
    #endif
}
