//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class OpaqueBaseViewCoordinator {
    public static var _runtimeLookup: [ObjectIdentifier: Unmanaged<OpaqueBaseViewCoordinator>] = [:]
    
    public let cancellables = Cancellables()
    
    open var environmentInsertions = EnvironmentInsertions()
    
    open internal(set) var children: [DynamicViewPresentable] = []
    
    public init() {
        Self._runtimeLookup[ObjectIdentifier(Self.self)] = Unmanaged.passUnretained(self)
    }
    
    deinit {
        Self._runtimeLookup[ObjectIdentifier(Self.self)] = nil
    }
    
    func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        update(withParent: parent)
    }
    
    func update(withParent parent: OpaqueBaseViewCoordinator) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let parent = parent as? _opaque_UIWindowCoordinator {
            if let self = self as? _opaque_UIWindowCoordinator {
                if self.window == nil {
                    self.window = parent.window
                }
            } else if let self = self as? _opaque_UIViewControllerCoordinator {
                if self.rootViewController == nil {
                    self.rootViewController = parent.window?.rootViewController
                }
            }
        } else if let parent = parent as? _opaque_UIViewControllerCoordinator {
            if let self = self as? _opaque_UIWindowCoordinator {
                if self.window == nil {
                    self.window = parent.rootViewController?.view.window
                }
            } else if let self = self as? _opaque_UIViewControllerCoordinator {
                if self.rootViewController == nil {
                    self.rootViewController = parent.rootViewController
                }
            }
        }
        #endif
    }
    
    func updateAllChildren() {
        for child in children {
            if let coordinator = child as? OpaqueBaseViewCoordinator {
                coordinator.update(withParent: self)
            }
        }
    }
}

open class BaseViewCoordinator<Route: Hashable>: OpaqueBaseViewCoordinator, ViewCoordinator {
    @inlinable
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentInsertions.insert(bindable)
        
        for child in children {
            if let child = child as? EnvironmentPropagator {
                child.insertEnvironmentObject(bindable)
            }
        }
    }
    
    @inlinable
    public func environment(_ builder: EnvironmentInsertions) {
        environmentInsertions.merge(builder)
        
        for child in children {
            if let child = child as? EnvironmentPropagator {
                child.environment(builder)
            }
        }
    }
    
    open func addChild(_ presentable: DynamicViewPresentable) {
        if let presentable = presentable as? EnvironmentPropagator {
            presentable.insertEnvironmentObject(AnyViewCoordinator(self))
        }
        
        if let presentable = presentable as? EnvironmentPropagator {
            presentable.environment(environmentInsertions)
        }
        
        if let presentable = presentable as? OpaqueBaseViewCoordinator {
            presentable.becomeChild(of: self)
        }
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        if let parent = parent as? EnvironmentPropagator {
            parent.insertEnvironmentObject(AnyViewCoordinator(self))
        }
        
        environment(parent.environmentInsertions)
        
        for child in children {
            if let child = child as? OpaqueBaseViewCoordinator {
                child.becomeChild(of: self)
            }
        }
    }
    
    @inlinable
    open func transition(for _: Route) -> ViewTransition {
        fatalError()
    }
    
    @inlinable
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    @discardableResult
    @inlinable
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        let publisher = triggerPublisher(for: route)
        let result = PassthroughSubject<ViewTransitionContext, Error>()
        
        publisher.subscribe(result, in: cancellables)
        
        return result.eraseToAnyPublisher()
    }
}
