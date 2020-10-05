//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class UIViewControllerCoordinator<Route: Hashable>: BaseViewCoordinator<Route>, DynamicViewPresenter {
    public var rootViewController: UIViewController
    
    @inlinable
    open var presentationName: ViewName? {
        rootViewController.presentationName
    }
    
    @inlinable
    open var presenter: DynamicViewPresenter? {
        nil
    }
    
    @inlinable
    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    @inlinable
    public convenience init<Route: Hashable>(parent: UIViewControllerCoordinator<Route>) {
        self.init(rootViewController: parent.rootViewController)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    @inlinable
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        transition(for: route)
            .mergeEnvironmentBuilder(environmentBuilder)
            .triggerPublisher(in: rootViewController, animated: true, coordinator: self)
    }
    
}

extension UIViewControllerCoordinator {
    @inlinable
    final public var presented: DynamicViewPresentable? {
        rootViewController.presented
    }
    
    @inlinable
    final public func present(_ presentation: AnyModalPresentation) {
        rootViewController.present(presentation)
    }
    
    @discardableResult
    @inlinable
    final public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController.dismiss(withAnimation: animation)
    }
    
    @discardableResult
    @inlinable
    final public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController.dismissSelf(withAnimation: animation)
    }
}

#endif
