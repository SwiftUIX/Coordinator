//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class AnyViewCoordinator<Route: Hashable>: ViewCoordinator {
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
}

public class EmptyViewCoordinator: ViewCoordinator {
    public typealias Route = Never
    
    public var environmentBuilder = EnvironmentBuilder()
    
    public init() {
        
    }
    
    public func transition(for: Never) -> ViewTransition {
        
    }
    
    public func triggerPublisher(for _: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        
    }
    
    public func trigger(_ : Route) -> AnyPublisher<ViewTransitionContext, Error> {
        
    }
}
