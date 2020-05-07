//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public protocol ViewTransitionContext {
    var animation: ViewTransitionAnimation { get }
    var view: EnvironmentalAnyView? { get }
}
