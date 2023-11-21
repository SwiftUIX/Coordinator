//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Merge
import Foundation
import Swallow
import SwiftUIX

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

public protocol AppKitOrUIKitViewControllerCoordinatorType: ViewCoordinator {
    var rootViewController: UIViewController? { get set }
}

open class UIViewControllerCoordinator<Route>: _AppKitOrUIKitViewCoordinatorBase<Route>, DynamicViewPresenter, AppKitOrUIKitViewControllerCoordinatorType {
    enum TriggerError: Error {
        case rootViewControllerMissing
    }
    
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
    
    open var presentationName: AnyHashable? {
        rootViewController?.presentationName
    }
    
    open var presenter: DynamicViewPresenter? {
        rootViewController?.presenter
    }
    
    public init(rootViewController: UIViewController? = nil) {
        self.rootViewController = rootViewController
    }
    
    public convenience init<T: Hashable>(parent: UIViewControllerCoordinator<T>) {
        self.init(rootViewController: parent.rootViewController)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        guard let rootViewController = rootViewController else {
            runtimeIssue("Could not resolve a root view controller.")
            
            return .failure(TriggerError.rootViewControllerMissing)
        }
        
        return transition(for: route)
            .environment(environmentInsertions)
            .triggerPublisher(in: rootViewController, animated: true, coordinator: self)
            .handleOutput { [weak self] _ in
                self?.updateAllChildren()
            }
            .eraseToAnyPublisher()
    }
    
}

extension UIViewControllerCoordinator {
    final public var presented: DynamicViewPresentable? {
        rootViewController?.presented
    }
    
    final public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        rootViewController?.present(presentation, completion: completion)
    }
    
    @discardableResult
    final public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController?.dismiss(withAnimation: animation) ?? .just(.success(false))
    }
    
    @discardableResult
    final public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController?.dismissSelf(withAnimation: animation) ?? .just(.success(false))
    }
}

#endif
