//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension UINavigationController {
    func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        pushViewController(viewController, animated: animated)
        
        CATransaction.commit()
    }
    
    func popViewController(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard animated else {
            popViewController(animated: false)

            return DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion?()
            }
        }
        
        if let coordinator = transitionCoordinator {
            popViewController(animated: animated)

            coordinator.animate(alongsideTransition: nil) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    completion?()
                }
            }
        } else {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                DispatchQueue.main.async {
                    completion?()
                }
            }
            
            popViewController(animated: animated)
            
            CATransaction.commit()
        }
    }
    
    func popToRootViewController(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        popToRootViewController(animated: animated)
        
        guard let completion = completion else {
            return
        }
        
        guard animated, let coordinator = transitionCoordinator else {
            return DispatchQueue.main.async(execute: { completion() })
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
}

#endif
