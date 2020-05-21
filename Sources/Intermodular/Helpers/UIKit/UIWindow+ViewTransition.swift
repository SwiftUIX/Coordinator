//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension ViewTransition {
    @usableFromInline
    func triggerPublisher<VC: ViewCoordinator>(
        in window: UIWindow,
        coordinator: VC
    ) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let transition = mergeCoordinator(coordinator)
        let animated = transition.animated
        
        if case .dynamic(let trigger) = transition.finalize() {
            return trigger()
        }
        
        return Future { attemptToFulfill in
            switch transition.finalize() {
                case .set(let view): do {
                    window.rootViewController = CocoaHostingController(rootView: view)
                }
                
                case .setNavigatable(let view): do {
                    window.rootViewController = UINavigationController(rootViewController: CocoaHostingController(rootView: view))
                }
                
                default: do {
                    do {
                        try window.rootViewController!.trigger(transition, animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } catch {
                        attemptToFulfill(.failure(.init(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
