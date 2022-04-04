//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol _opaque_UIWindowCoordinator: AnyObject {
    var window: UIWindow? { get set }
}

public protocol UIWindowCoordinatorProtocol: _opaque_UIWindowCoordinator, ViewCoordinator {
    var window: UIWindow? { get set }
}

open class UIWindowCoordinator<Route: Hashable>: BaseViewCoordinator<Route>, _opaque_UIWindowCoordinator {
    public var window: UIWindow? {
        willSet {
            objectWillChange.send()
        } didSet {
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
    
    convenience public init<Route: Hashable>(parent: UIWindowCoordinator<Route>) {
        self.init(window: parent.window)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    @discardableResult
    override public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        do {
            let window = try self.window.unwrap()
            
            return transition(for: route)
                .environment(environmentInsertions)
                .triggerPublisher(in: window, coordinator: self)
                .handleOutput { [weak self] _ in
                    self?.updateAllChildren()
                }
                .handleSubscription({ _ in window.makeKeyAndVisible() })
                .eraseToAnyPublisher()
        } catch {
            return .failure(error)
        }
    }
    
    @discardableResult
    override public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        super.trigger(route)
    }
}

extension UIWindowCoordinator: DynamicViewPresenter {
    open var presenter: DynamicViewPresenter? {
        nil
    }
    
    final public var presented: DynamicViewPresentable? {
        window?.presented
    }
    
    final public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        window?.present(presentation, completion: completion)
    }
    
    @discardableResult
    final public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        window?.dismiss(withAnimation: animation) ?? .just(.success(false))
    }
    
    @discardableResult
    final public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        window?.dismissSelf(withAnimation: animation)  ?? .just(.success(false))
    }
}

#endif
