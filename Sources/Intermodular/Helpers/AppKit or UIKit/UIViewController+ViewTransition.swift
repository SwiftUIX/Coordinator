//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import SwiftUIX

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

extension UIViewController {
    public func trigger(
        _ transition: ViewTransition,
        completion: @escaping () -> ()
    ) throws {
        switch transition.finalize() {
            case .present(let view): do {
                presentOnTop(view, named: transition.payloadViewName, animated: transition.animated) {
                    completion()
                }
            }
                
            case .replace(let view): do {
                if let viewController = topmostPresentedViewController?.presentingViewController {
                    viewController.dismiss(animated: transition.animated) {
                        viewController.presentOnTop(
                            view,
                            named: transition.payloadViewName,
                            animated: transition.animated
                        ) {
                            completion()
                        }
                    }
                } else {
                    presentOnTop(view, named: transition.payloadViewName, animated: transition.animated) {
                        completion()
                    }
                }
            }
                
            case .dismiss: do {
                guard presentedViewController != nil else {
                    throw ViewTransition.Error.nothingToDismiss
                }
                
                dismiss(animated: transition.animated) {
                    completion()
                }
            }
                
            case .dismissView(let name): do {
                _ = dismissView(named: name)
                    .onOutput(do: completion())
                    .retainSink()
            }
                
            case .push(let view): do {
                guard let navigationController = nearestNavigationController else {
                    throw ViewTransition.Error.navigationControllerMissing
                }
                
                navigationController.pushViewController(
                    view._toAppKitOrUIKitViewController(),
                    animated: transition.animated
                ) {
                    completion()
                }
            }
                
            case .pushOrPresent(let view): do {
                if let navigationController = nearestNavigationController {
                    navigationController.pushViewController(
                        view._toAppKitOrUIKitViewController(),
                        animated: transition.animated
                    ) {
                        completion()
                    }
                } else {
                    presentOnTop(view, named: transition.payloadViewName, animated: transition.animated) {
                        completion()
                    }
                }
            }
                
            case .pop: do {
                guard let viewController = nearestNavigationController else {
                    throw ViewTransition.Error.navigationControllerMissing
                }
                
                viewController.popViewController(animated: transition.animated) {
                    completion()
                }
            }
                
            case .popToRoot: do {
                guard let viewController = nearestNavigationController else {
                    throw ViewTransition.Error.navigationControllerMissing
                }
                
                viewController.popToRootViewController(animated: transition.animated) {
                    completion()
                }
            }
                
            case .popOrDismiss: do {
                if let navigationController = nearestNavigationController, navigationController.viewControllers.count > 1 {
                    navigationController.popViewController(animated: transition.animated) {
                        completion()
                    }
                } else {
                    guard presentedViewController != nil else {
                        throw ViewTransition.Error.nothingToDismiss
                    }
                    
                    dismiss(animated: transition.animated) {
                        completion()
                    }
                }
            }
                
            case .popToRootOrDismiss: do {
                if let navigationController = nearestNavigationController, navigationController.viewControllers.count > 1 {
                    navigationController.popToRootViewController(animated: transition.animated) {
                        completion()
                    }
                } else {
                    guard presentedViewController != nil else {
                        throw ViewTransition.Error.nothingToDismiss
                    }
                    
                    dismiss(animated: transition.animated) {
                        completion()
                    }
                }
            }
                
            case .setRoot(let view): do {
                if let viewController = self as? CocoaHostingController<AnyPresentationView> {
                    viewController.rootView.content = view
                    
                    completion()
                } else if let window = self.view.window, window.rootViewController === self {
                    window.rootViewController = view._toAppKitOrUIKitViewController()
                    
                    completion()
                } else {
                    throw ViewTransition.Error.cannotSetRoot
                }
            }
                
            case .set(let view, _): do {
                if let viewController = nearestNavigationController {
                    viewController.setViewControllers([view._toAppKitOrUIKitViewController()], animated: transition.animated)
                    
                    completion()
                } else if let window = self.view.window, window.rootViewController === self {
                    window.rootViewController = view._toAppKitOrUIKitViewController()
                    
                    completion()
                } else if let viewController = self as? CocoaHostingController<AnyPresentationView> {
                    viewController.rootView.content = view
                    
                    completion()
                } else if topmostPresentedViewController != nil {
                    dismiss(animated: transition.animated) {
                        self.presentOnTop(view, named: transition.payloadViewName, animated: transition.animated) {
                            completion()
                        }
                    }
                }
            }
            
            case .setMany(let views): do {
                guard let navigationController = nearestNavigationController else {
                    throw ViewTransition.Error.navigationControllerMissing
                }
                
                navigationController.setViewControllers(
                    views.map { $0._toAppKitOrUIKitViewController() },
                    animated: transition.animated
                ) {
                    completion()
                }
            }
                
            case .linear(var transitions): do {
                guard !transitions.isEmpty else {
                    return completion()
                }
                
                var _error: Error?
                
                var firstTransition = transitions.removeFirst()
                firstTransition.animated = transition.animated && firstTransition.animated
                
                try trigger(firstTransition) {
                    do {
                        try self.trigger(.linear(transitions)) {
                            completion()
                        }
                    } catch {
                        _error = error
                    }
                }
                
                if let error = _error {
                    throw error
                }
            }
                
            case .custom: do {
                throw runtimeIssue(.unavailable)
            }
                
            case .none:
                break
        }
    }
    
    func presentOnTop(
        _ view: AnyPresentationView,
        named viewName: AnyHashable?,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        topmostViewController.present(view)
    }
}

extension ViewTransition {
    @_transparent
    func triggerPublisher<VC: ViewCoordinator>(
        in controller: UIViewController,
        coordinator: VC
    ) -> AnyPublisher<ViewTransitionContext, Swift.Error> {
        let transition = merge(coordinator: coordinator)
        
        if case .custom(let trigger) = transition.finalize() {
            return trigger(animated)
        }
        
        return Future { attemptToFulfill in
            do {
                try controller.trigger(transition) {
                    attemptToFulfill(.success(transition))
                }
            } catch {                
                attemptToFulfill(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
