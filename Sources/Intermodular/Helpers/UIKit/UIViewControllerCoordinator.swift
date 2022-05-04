//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Merge
import Foundation
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol _opaque_UIViewControllerCoordinator: AnyObject {
    var rootViewController: UIViewController? { get set }
}

public protocol UIViewControllerCoordinatorProtocol: _opaque_UIViewControllerCoordinator, ViewCoordinator {
    var rootViewController: UIViewController? { get set }
}

open class UIViewControllerCoordinator<Route>: BaseViewCoordinator<Route>, DynamicViewPresenter, UIViewControllerCoordinatorProtocol {
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
    
    public convenience init<Route: Hashable>(parent: UIViewControllerCoordinator<Route>) {
        self.init(rootViewController: parent.rootViewController)
        
        parent.addChild(self)
    }
    
    override open func transition(for route: Route) -> ViewTransition {
        fatalError()
    }
    
    public override func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        guard let rootViewController = rootViewController else {
            XcodeRuntimeIssueLogger.default.log(.error, message: "Could not resolve a root view controller.")

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
