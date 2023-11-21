//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import SwiftUIX

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
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
                case .set(let view, let transition): do {                    
                    if let transition {
                        switch transition {
                            case ._appKitOrUIKitBlockAnimation(let animation, let duration):
                                window.rootViewController = CocoaHostingController(mainView: view)
                                
                                if !window.isKeyWindow {
                                    window.makeKeyAndVisible()
                                }
                                
                                UIView.transition(
                                    with: window,
                                    duration: duration,
                                    options: animation,
                                    animations: nil
                                ) { completion in
                                    if completion {
                                        attemptToFulfill(.success(self))
                                    } else {
                                        attemptToFulfill(.failure(_PlaceholderError()))
                                    }
                                }
                        }
                    } else {
                        window.rootViewController = CocoaHostingController(mainView: view)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                            attemptToFulfill(.success(self))
                        }
                    }
                }
                default: do {
                    do {
                        try window.rootViewController.unwrap().trigger(transition, animated: animated) {
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
