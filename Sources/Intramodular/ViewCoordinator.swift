//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public protocol ViewCoordinator: EnvironmentProvider, ViewRouter {    
    func transition(for: Route) -> ViewTransition
}

// MARK: - API -

extension ActionLabelView {
    public init<Coordinator: ViewCoordinator>(
        trigger route: Coordinator.Route,
        in coordinator: Coordinator,
        @ViewBuilder label: () -> Label
    ) {
        self.init(action: { coordinator.trigger(route) }, label: label)
    }
}
