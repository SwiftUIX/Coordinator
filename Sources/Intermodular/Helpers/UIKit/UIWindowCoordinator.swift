//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol UIWindowCoordinatorProtocol: ViewCoordinator {
    var window: UIWindow { get }
    
    init(window: UIWindow)
}

open class UIWindowCoordinator<Route: ViewRoute>: BaseViewCoordinator<Route>, UIWindowCoordinatorProtocol {
    public var window: UIWindow
    
    @inlinable
    override open var presentationName: ViewName? {
        window.presentationName
    }
    
    @inlinable
    public required init(window: UIWindow) {
        self.window = window
    }
    
    @inlinable
    convenience public init<Route: ViewRoute>(parent: UIWindowCoordinator<Route>) {
        self.init(window: parent.window)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    @discardableResult
    @inlinable
    override public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        return transition(for: route)
            .mergeEnvironmentBuilder(environmentBuilder)
            .triggerPublisher(in: window, coordinator: self)
            .handleSubscription({ _ in self.window.makeKeyAndVisible() })
            .eraseToAnyPublisher()
    }
}

extension UIWindowCoordinator: DynamicViewPresenter {
    @inlinable
    final public var presented: DynamicViewPresentable? {
        window.presented
    }
    
    @inlinable
    final public func present(_ presentation: AnyModalPresentation) {
        window.present(presentation)
    }
    
    @inlinable
    final public func dismiss(animated: Bool, completion: (() -> Void)?) {
        window.dismiss(animated: animated, completion: completion)
    }
}

#endif
