//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class UIViewControllerCoordinator<Route: ViewRoute>: BaseViewCoordinator<Route>, DynamicViewPresenter {
    public var rootViewController: UIViewController
    
    @inlinable
    override open var name: ViewName? {
        rootViewController.name
    }
    
    @inlinable
    open var presented: DynamicViewPresentable? {
        rootViewController.presented
    }
    
    @inlinable
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    @inlinable
    public convenience init<Route: ViewRoute>(parent: UIViewControllerCoordinator<Route>) {
        self.init(rootViewController: parent.rootViewController)
        
        parent.addChild(self)
    }
    
    @inlinable
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        transition(for: route)
            .mergeEnvironmentBuilder(environmentBuilder)
            .triggerPublisher(in: rootViewController, animated: true, coordinator: self)
    }
    
    @inlinable
    public func present(_ presentation: AnyModalPresentation) {
        rootViewController.present(presentation)
    }
    
    @inlinable
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        rootViewController.dismiss(animated: animated, completion: completion)
    }
}

open class UIWindowCoordinator<Route: ViewRoute>: BaseViewCoordinator<Route>, DynamicViewPresenter {
    public var window: UIWindow
    
    @inlinable
    override open var name: ViewName? {
        window.name
    }
    
    @inlinable
    open var presented: DynamicViewPresentable? {
        window.presented
    }
    
    @inlinable
    public init(window: UIWindow) {
        self.window = window
    }
    
    @inlinable
    public convenience init<Route: ViewRoute>(parent: UIWindowCoordinator<Route>) {
        self.init(window: parent.window)
        
        parent.addChild(self)
    }
    
    @discardableResult
    @inlinable
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        return transition(for: route)
            .mergeEnvironmentBuilder(environmentBuilder)
            .triggerPublisher(in: window, coordinator: self)
            .handleSubscription({ _ in self.window.makeKeyAndVisible() })
            .eraseToAnyPublisher()
    }
    
    @inlinable
    public func present(_ presentation: AnyModalPresentation) {
        window.present(presentation)
    }
    
    @inlinable
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        window.dismiss(animated: animated, completion: completion)
    }
}

#endif
