//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIViewController {
    @inlinable
    public func trigger(
        _ transition: ViewTransition,
        animated: Bool,
        completion: @escaping () -> ()
    ) throws {
        switch transition.finalize() {
            case .present(let view): do {
                presentOnTop(view, named: transition.payloadViewName, animated: animated) {
                    completion()
                }
            }
            
            case .replacePresented(let view): do {
                if let viewController = topmostPresentedViewController?.presentingViewController {
                    viewController.dismiss(animated: animated) {
                        viewController.presentOnTop(view, named: transition.payloadViewName, animated: animated) {
                            completion()
                        }
                    }
                } else {
                    presentOnTop(view, named: transition.payloadViewName, animated: animated) {
                        completion()
                    }
                }
            }
            
            case .dismiss: do {
                guard presentedViewController != nil else {
                    throw ViewRouterError.transitionError(.nothingToDismiss)
                }
                
                dismiss(animated: animated) {
                    completion()
                }
            }
            
            case .dismissView(let name): do {
                dismissView(named: name) { // FIXME: Does not respect `animated`!
                    completion()
                }
            }
            
            case .push(let view): do {
                guard let navigationController = topmostNavigationController else {
                    throw ViewRouterError.transitionError(.navigationControllerMissing)
                }
                
                navigationController.pushViewController(
                    CocoaHostingController(rootView: view),
                    animated: animated
                ) {
                    completion()
                }
            }
            
            case .pushOrPresent(let view): do {
                if let navigationController = topmostNavigationController {
                    navigationController.pushViewController(
                        CocoaHostingController(rootView: view),
                        animated: animated
                    ) {
                        completion()
                    }
                } else {
                    presentOnTop(view, named: transition.payloadViewName, animated: animated) {
                        completion()
                    }
                }
            }
            
            case .pop: do {
                guard let viewController = topmostNavigationController else {
                    throw ViewRouterError.transitionError(.navigationControllerMissing)
                }
                
                viewController.popViewController(animated: animated) {
                    completion()
                }
            }
            
            case .popToRoot: do {
                guard let viewController = topmostNavigationController else {
                    throw ViewRouterError.transitionError(.navigationControllerMissing)
                }
                
                viewController.popToRootViewController(animated: animated) {
                    completion()
                }
            }
            
            case .popOrDismiss: do {
                if let navigationController = topmostNavigationController, navigationController.viewControllers.count > 1 {
                    navigationController.popViewController(animated: animated) {
                        completion()
                    }
                } else {
                    guard presentedViewController != nil else {
                        throw ViewRouterError.transitionError(.nothingToDismiss)
                    }
                    
                    dismiss(animated: animated) {
                        completion()
                    }
                }
            }
            
            case .setRoot(let view): do {
                if let viewController = self as? CocoaHostingController<EnvironmentalAnyView> {
                    viewController.rootViewContent = view
                    
                    completion()
                } else if let window = self.view.window, window.rootViewController === self {
                    window.rootViewController = CocoaHostingController(rootView: view)
                    
                    completion()
                } else {
                    throw ViewTransition.Error.cannotSetRoot
                }
            }
            
            case .set(let view): do {
                if let viewController = topmostNavigationController {
                    viewController.setViewControllers([CocoaHostingController(rootView: view)], animated: animated)
                    
                    completion()
                } else if let window = self.view.window, window.rootViewController === self {
                    window.rootViewController = CocoaHostingController(rootView: view)
                    
                    completion()
                } else if let viewController = self as? CocoaHostingController<EnvironmentalAnyView> {
                    viewController.rootViewContent = view
                    
                    completion()
                } else if topmostPresentedViewController != nil {
                    dismiss(animated: animated) {
                        self.presentOnTop(view, named: transition.payloadViewName, animated: animated) {
                            completion()
                        }
                    }
                }
            }
            
            case .setNavigatable(let view): do {
                if topmostPresentedViewController != nil {
                    dismiss(animated: animated) {
                        self.presentOnTop(view, named: transition.payloadViewName, animated: animated) {
                            completion()
                        }
                    }
                } else if let viewController = topmostNavigationController {
                    viewController.setViewControllers([CocoaHostingController(rootView: view)], animated: animated)
                    
                    completion()
                } else if let window = self.view.window, window.rootViewController === self {
                    window.rootViewController = UINavigationController(rootViewController: CocoaHostingController(rootView: view))
                    
                    completion()
                }
            }
            
            case .linear(var transitions): do {
                guard !transitions.isEmpty else {
                    return completion()
                }
                
                var _error: Error?
                
                try trigger(transitions.removeFirst(), animated: animated) {
                    do {
                        try self.trigger(.linear(transitions), animated: animated) {
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
            
            case .dynamic: do {
                fatalError()
            }
            
            case .none:
                break
        }
    }
    
    public func presentOnTop<V: View>(
        _ view: V,
        named viewName: ViewName?,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        topmostViewController.present(view, named: viewName, completion: completion)
    }
}

extension ViewTransition {
    @usableFromInline
    func triggerPublisher<VC: ViewCoordinator>(in controller: UIViewController, animated: Bool, coordinator: VC) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let transition = mergeCoordinator(coordinator)
        
        if case .dynamic(let trigger) = transition.finalize() {
            return trigger()
        }
        
        return Future { attemptToFulfill in
            do {
                try controller.trigger(transition, animated: animated) {
                    attemptToFulfill(.success(transition))
                }
            } catch {
                attemptToFulfill(.failure(.init(error)))
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
