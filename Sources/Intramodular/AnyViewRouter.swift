//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class AnyViewRouter<Route: ViewRoute>: ViewRouter {
    public let base: DynamicViewPresentable
    
    public var name: ViewName? {
        base.name
    }
    
    public var presenter: DynamicViewPresenter? {
        base.presenter
    }
    
    private let transitionImpl: (Route) -> ViewTransition
    private let triggerPublisherImpl: (Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    private let triggerImpl: (Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    
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
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        triggerPublisherImpl(route)
    }
    
    @discardableResult
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        triggerImpl(route)
    }
}
