//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol UIWindowCoordinatorProtocol: ViewCoordinator {
    var window: UIWindow? { get }
    
    init(window: UIWindow?)
}

open class UIWindowCoordinator<Route: Hashable>: BaseViewCoordinator<Route>, UIWindowCoordinatorProtocol {
    public var window: UIWindow?
    
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        window?._cocoaPresentationCoordinator ?? .init()
    }

    @inlinable
    open var presentationName: ViewName? {
        window?.presentationName
    }
    
    @inlinable
    public required init(window: UIWindow? = nil) {
        self.window = window
    }
    
    @inlinable
    convenience public init<Route: Hashable>(parent: UIWindowCoordinator<Route>) {
        self.init(window: parent.window)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    @discardableResult
    @inlinable
    override public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        do {
            let window = try self.window.unwrap()
            
            return transition(for: route)
                .mergeEnvironmentBuilder(environmentBuilder)
                .triggerPublisher(in: window, coordinator: self)
                .handleSubscription({ _ in window.makeKeyAndVisible() })
                .eraseToAnyPublisher()
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    @inlinable
    override public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        super.trigger(route)
    }
}

extension UIWindowCoordinator: DynamicViewPresenter {    
    @inlinable
    open var presenter: DynamicViewPresenter? {
        nil
    }
    
    @inlinable
    final public var presented: DynamicViewPresentable? {
        window?.presented
    }
    
    @inlinable
    final public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        window?.present(presentation, completion: completion)
    }
    
    @discardableResult
    @inlinable
    final public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        window?.dismiss(withAnimation: animation) ?? .just(.success(false))
    }
    
    @discardableResult
    @inlinable
    final public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        window?.dismissSelf(withAnimation: animation)  ?? .just(.success(false))
    }
}

#endif
