//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public struct ViewTransition {
    public enum Error: Swift.Error {
        case cannotPopRoot
        case isRoot
        case nothingToDismiss
        case navigationControllerMissing
        case cannotSetRoot
    }
    
    private var payload: Payload
    
    @usableFromInline
    var animated: Bool = true
    @usableFromInline
    var payloadViewName: ViewName?
    @usableFromInline
    var payloadViewType: Any.Type?
    @usableFromInline
    var environmentBuilder: EnvironmentBuilder
    
    @usableFromInline
    init<V: View>(payload: (EnvironmentalAnyView) -> ViewTransition.Payload, view: V) {
        self.payload = payload(.init(view))
        self.payloadViewName = (view as? _opaque_NamedView)?.name
        self.payloadViewType = type(of: view)
        self.environmentBuilder = .init()
    }
    
    @usableFromInline
    init(payload: ViewTransition.Payload) {
        self.payload = payload
        self.payloadViewName = nil
        self.payloadViewType = nil
        self.environmentBuilder = .init()
    }
    
    @usableFromInline
    func finalize() -> Payload {
        var result = payload
        
        result.mutateViewInPlace({
            $0.mergeEnvironmentBuilderInPlace(environmentBuilder)
        })
        
        return result
    }
}

extension ViewTransition {
    public var revert: ViewTransition? {
        switch payload {
            case .present:
                return .dismiss
            case .replace:
                return nil
            case .dismiss:
                return nil
            case .dismissView:
                return nil
            case .push:
                return .pop
            case .pushOrPresent:
                return .popOrDismiss
            case .pop:
                return nil
            case .popToRoot:
                return nil
            case .popOrDismiss:
                return nil
            case .popToRootOrDismiss:
                return nil
            case .set:
                return nil
            case .setRoot:
                return nil
            case .setNavigatable:
                return nil
            case .linear:
                return nil
            case .dynamic:
                return nil
            case .none:
                return ViewTransition.none
        }
    }
}

// MARK: - Protocol Implementations -

extension ViewTransition: ViewTransitionContext {
    @inlinable
    public var animation: ViewTransitionAnimation {
        DefaultViewTransitionAnimation()
    }
    
    @inlinable
    public var view: EnvironmentalAnyView? {
        finalize().view
    }
}

// MARK: - API -

extension ViewTransition {
    @inlinable
    public static func present<V: View>(_ view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.present, view: view)
    }
    
    @inlinable
    public static func replace<V: View>(with view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.replace, view: view)
    }
    
    @inlinable
    public static var dismiss: ViewTransition {
        .init(payload: .dismiss)
    }
    
    @inlinable
    public static func dismissView<H: Hashable>(named name: H) -> ViewTransition {
        .init(payload: .dismissView(named: .init(name)))
    }
    
    @inlinable
    public static func push<V: View>(_ view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.push, view: view)
    }
    
    @inlinable
    public static func pushOrPresent<V: View>(_ view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.pushOrPresent, view: view)
    }
    
    @inlinable
    public static var pop: ViewTransition {
        .init(payload: .pop)
    }
    
    @inlinable
    public static var popToRoot: ViewTransition {
        .init(payload: .popToRoot)
    }
    
    @inlinable
    public static var popOrDismiss: ViewTransition {
        .init(payload: .popOrDismiss)
    }
    
    @inlinable
    public static var popToRootOrDismiss: ViewTransition {
        .init(payload: .popToRootOrDismiss)
    }
    
    @inlinable
    public static func set<V: View>(_ view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.set, view: view)
    }
    
    @inlinable
    public static func setRoot<V: View>(_ view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.setRoot, view: view)
    }
    
    @inlinable
    public static func setNavigatable<V: View>(_ view: V) -> ViewTransition {
        .init(payload: ViewTransition.Payload.setNavigatable, view: view)
    }
    
    @inlinable
    public static func linear(_ transitions: [ViewTransition]) -> ViewTransition {
        .init(payload: .linear(transitions))
    }
    
    @inlinable
    public static func linear(_ transitions: ViewTransition...) -> ViewTransition {
        linear(transitions)
    }
    
    @inlinable
    public static func dynamic(
        _ body: @escaping () -> AnyPublisher<ViewTransitionContext, ViewRouterError>
    ) -> ViewTransition {
        .init(payload: .dynamic(body))
    }
    
    @inlinable
    public static var none: ViewTransition {
        .init(payload: .none)
    }
}

extension ViewTransition {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> ViewTransition {
        var result = self
        
        result.environmentBuilder.merge(builder)
        
        return result
    }
    
    public func mergeCoordinator<VC: ViewCoordinator>(_ coordinator: VC) -> Self {
        mergeEnvironmentBuilder(.object(coordinator))
            .mergeEnvironmentBuilder(.object(AnyViewCoordinator(coordinator)))
    }
}

// MARK: - Helpers -

extension ViewTransition.Payload {
    mutating func mutateViewInPlace(_ body: (inout EnvironmentalAnyView) -> Void) {
        switch self {
            case .linear(let transitions):
                self = .linear(transitions.map({
                    var transition = $0
                    
                    transition.mutateViewInPlace(body)
                    
                    return transition
                }))
            default: do {
                if var view = self.view {
                    body(&view)
                    
                    self.view = view
                }
            }
        }
    }
}

extension ViewTransition {
    mutating func mutateViewInPlace(_ body: (inout EnvironmentalAnyView) -> Void) {
        switch payload {
            case .linear(let transitions):
                payload = .linear(transitions.map({
                    var transition = $0
                    
                    transition.mutateViewInPlace(body)
                    
                    return transition
                }))
            default: do {
                if var view = payload.view {
                    body(&view)
                    
                    payload.view = view
                }
            }
        }
    }
}
