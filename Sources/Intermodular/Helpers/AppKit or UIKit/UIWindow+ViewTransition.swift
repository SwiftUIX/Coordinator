//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUIX

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension ViewTransition {
    func triggerPublisher<Coordinator: ViewCoordinator>(
        in window: AppKitOrUIKitWindow,
        coordinator: Coordinator
    ) -> AnyPublisher<ViewTransitionContext, Swift.Error> {
        let transition = merge(coordinator: coordinator)
        let animated = transition.animated
        
        if case .custom(let trigger) = transition.finalize() {
            return trigger()
        }
        
        return Future { attemptToFulfill in
            switch transition.finalize() {
                case .set(let view): do {
                    window.rootViewController = CocoaHostingController(mainView: view)
                    
                    attemptToFulfill(.success(self))
                }
                    
                default: do {
                    do {
                        try window.rootViewController!.trigger(transition, animated: animated) {
                            attemptToFulfill(.success(self))
                        }
                    } catch {
                        attemptToFulfill(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif
