//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol ViewCoordinator: EnvironmentPropagator, ObservableObject {
    associatedtype Route
    
    typealias Transition = ViewTransition
    
    func triggerPublisher(for _: Route) -> AnyPublisher<ViewTransitionContext, Error>
    
    @discardableResult
    @MainActor
    func trigger(_: Route) -> AnyPublisher<ViewTransitionContext, Error>
    
    func transition(for: Route) -> Transition
}
