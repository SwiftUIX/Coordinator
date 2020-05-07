//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension UINavigationController {
    @usableFromInline
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
    
    @usableFromInline
    func popViewController(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        popViewController(animated: animated)
        
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
    
    @usableFromInline
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
