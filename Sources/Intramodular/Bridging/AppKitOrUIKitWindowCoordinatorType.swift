//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
public typealias UIWindowCoordinator = AppKitOrUIKitWindowCoordinator
#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
public protocol AppKitOrUIKitWindowCoordinatorType: ViewCoordinator {
    var window: UIWindow? { get set }
}

open class AppKitOrUIKitWindowCoordinator<Route>: _AppKitOrUIKitViewCoordinatorBase<Route> {
    public var window: UIWindow? {
        willSet {
            guard window !== newValue else {
                return
            }
            
            objectWillChange.send()
        } didSet {
            guard oldValue !== window else {
                return
            }
            
            updateAllChildren()
        }
    }
    
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        window?._cocoaPresentationCoordinator ?? .init()
    }
    
    open var presentationName: AnyHashable? {
        window?.presentationName
    }
    
    public init(window: UIWindow? = nil) {
        self.window = window
    }
    
    convenience public init<Route: Hashable>(parent: AppKitOrUIKitWindowCoordinator<Route>) {
        self.init(window: parent.window)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    @discardableResult
    override public func triggerPublisher(
        for route: Route
    ) -> AnyPublisher<ViewTransitionContext, Error> {
        do {
            let window = try self.window.unwrap()
            
            return transition(for: route)
                .environment(environmentInsertions)
                .triggerPublisher(in: window, coordinator: self)
                .handleOutput { [weak self] _ in
                    self?.updateAllChildren()
                }
                .handleSubscription { _ in
                    if !window.isKeyWindow {
                        window.makeKeyAndVisible()
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    override public func trigger(
        _ route: Route
    ) -> AnyPublisher<ViewTransitionContext, Error> {
        super.trigger(route)
    }
}

extension AppKitOrUIKitWindowCoordinator: DynamicViewPresenter {
    public var presenter: DynamicViewPresenter? {
        nil
    }
    
    final public var presented: DynamicViewPresentable? {
        window?.presented
    }
    
    final public func present(
        _ presentation: AnyModalPresentation,
        completion: @escaping () -> Void
    ) {
        window?.present(presentation, completion: completion)
    }
    
    @discardableResult
    final public func dismiss(
        withAnimation animation: Animation?
    ) -> Future<Bool, Never> {
        window?.dismiss(withAnimation: animation) ?? .just(.success(false))
    }
    
    @discardableResult
    final public func dismissSelf(
        withAnimation animation: Animation?
    ) -> Future<Bool, Never> {
        window?.dismissSelf(withAnimation: animation)  ?? .just(.success(false))
    }
}
#endif
