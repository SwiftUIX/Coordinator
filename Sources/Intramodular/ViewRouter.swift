//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public enum ViewRouterError: Error {
    case transitionError(ViewTransition.Error)
    case unknown(Error)
    
    public init(_ error: Error) {
        if let error = error as? ViewTransition.Error {
            self = .transitionError(error)
        } else {
            self = .unknown(error)
        }
    }
}

public protocol ViewRouter: ObservableObject, DynamicViewPresentable {
    associatedtype Route: ViewRoute
    
    func triggerPublisher(for _: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    
    @discardableResult
    func trigger(_: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError>
}
