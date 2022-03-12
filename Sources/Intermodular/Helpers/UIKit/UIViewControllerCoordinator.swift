//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol _opaque_UIViewControllerCoordinator: AnyObject {
    var rootViewController: UIViewController? { get set }
    
    init(rootViewController: UIViewController?)
}

public protocol UIViewControllerCoordinatorProtocol: _opaque_UIViewControllerCoordinator, ViewCoordinator {
    var rootViewController: UIViewController? { get set }
    
    init(rootViewController: UIViewController?)
}

open class UIViewControllerCoordinator<Route>: BaseViewCoordinator<Route>, DynamicViewPresenter, UIViewControllerCoordinatorProtocol {
    public var rootViewController: UIViewController? {
        willSet {
            objectWillChange.send()
        } didSet {
            updateAllChildren()
        }
    }
    
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        rootViewController?._cocoaPresentationCoordinator ?? .init()
    }
    
    @inlinable
    open var presentationName: AnyHashable? {
        rootViewController?.presentationName
    }
    
    @inlinable
    open var presenter: DynamicViewPresenter? {
        rootViewController?.presenter
    }
    
    @inlinable
    public required init(rootViewController: UIViewController? = nil) {
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
    
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        do {
            return transition(for: route)
                .environment(environmentInsertions)
                .triggerPublisher(in: try rootViewController.unwrap(), animated: true, coordinator: self)
                .handleOutput { [weak self] _ in
                    self?.updateAllChildren()
                }
                .eraseToAnyPublisher()
        } catch {
            return .failure(error)
        }
    }
    
}

extension UIViewControllerCoordinator {
    @inlinable
    final public var presented: DynamicViewPresentable? {
        rootViewController?.presented
    }
    
    @inlinable
    final public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        rootViewController?.present(presentation, completion: completion)
    }
    
    @discardableResult
    @inlinable
    final public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController?.dismiss(withAnimation: animation) ?? .just(.success(false))
    }
    
    @discardableResult
    @inlinable
    final public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController?.dismissSelf(withAnimation: animation) ?? .just(.success(false))
    }
}

#endif
