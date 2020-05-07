//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

/// A control which dispatches a reactor action when triggered.
public struct ViewCoordinatorButton<Route: ViewRoute, Label: View>: View {
    private let route: Route
    private let trigger: () -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    
    private let label: Label
    
    public init<Router: ViewRouter>(route: Route, router: Router, label: () -> Label) where Router.Route == Route {
        self.route = route
        self.trigger = { router.trigger(route) }
        self.label = label()
    }
    
    public var body: some View {
        Button(action: { _ = self.trigger() }, label: { label })
    }
}

// MARK: - API -

extension ViewCoordinator {
    public func button<Label: View>(
        for route: Route,
        label: () -> Label
    ) -> some View {
        ViewCoordinatorButton(route: route, router: self, label: label)
    }
}
