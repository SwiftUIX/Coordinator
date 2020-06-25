//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

public final class AnyViewRouter<Route: ViewRoute>: ViewRouter {
    public let base: DynamicViewPresentable
    
    public var presentationName: ViewName? {
        base.presentationName
    }
    
    public var presenter: DynamicViewPresenter? {
        base.presenter
    }
    
    private let triggerPublisherImpl: (Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    private let triggerImpl: (Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    
    public init<Router: ViewRouter>(_ router: Router) where Router.Route == Route {
        self.base = router
        
        self.triggerPublisherImpl = router.triggerPublisher
        self.triggerImpl = router.trigger
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
