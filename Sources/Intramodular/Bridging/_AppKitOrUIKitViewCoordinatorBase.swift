//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

var _coordinatorRuntimeLookup: [ObjectIdentifier: Unmanaged<_opaque_AppKitOrUIKitViewCoordinatorBase>] = [:]

@MainActor
open class _opaque_AppKitOrUIKitViewCoordinatorBase {
    fileprivate let cancellables = Cancellables()
    
    open var environmentInsertions = EnvironmentInsertions()
    
    open internal(set) var children: [DynamicViewPresentable] = []
    
    public init() {
        _coordinatorRuntimeLookup[ObjectIdentifier(Self.self)] = Unmanaged.passUnretained(self)
    }
    
    deinit {
        _coordinatorRuntimeLookup[ObjectIdentifier(Self.self)] = nil
    }
    
    func becomeChild(of parent: _opaque_AppKitOrUIKitViewCoordinatorBase) {
        update(withParent: parent)
    }
    
    func update(withParent parent: _opaque_AppKitOrUIKitViewCoordinatorBase) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let parent = parent as? any AppKitOrUIKitWindowCoordinatorType {
            if let self = self as? any AppKitOrUIKitWindowCoordinatorType {
                if self.window == nil {
                    self.window = parent.window
                }
            } else if let self = self as? any AppKitOrUIKitViewControllerCoordinatorType {
                if self.rootViewController == nil {
                    self.rootViewController = parent.window?.rootViewController
                }
            }
        } else if let parent = parent as? any AppKitOrUIKitViewControllerCoordinatorType {
            if let self = self as? any AppKitOrUIKitWindowCoordinatorType {
                if self.window == nil {
                    self.window = parent.rootViewController?.view.window
                }
            } else if let self = self as? any AppKitOrUIKitViewControllerCoordinatorType {
                if self.rootViewController == nil {
                    self.rootViewController = parent.rootViewController
                }
            }
        }
        #endif
    }
    
    func updateAllChildren() {
        for child in children {
            if let coordinator = child as? _opaque_AppKitOrUIKitViewCoordinatorBase {
                coordinator.update(withParent: self)
            }
        }
    }
}

open class _AppKitOrUIKitViewCoordinatorBase<Route>: _opaque_AppKitOrUIKitViewCoordinatorBase, ViewCoordinator {
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentInsertions.insert(bindable)
        
        for child in children {
            if let child = child as? EnvironmentPropagator {
                child.insertEnvironmentObject(bindable)
            }
        }
    }
    
    public func insert(contentsOf insertions: EnvironmentInsertions) {
        environmentInsertions.merge(insertions)
        
        for child in children {
            if let child = child as? EnvironmentPropagator {
                child.insert(contentsOf: insertions)
            }
        }
    }
    
    open func addChild(_ presentable: DynamicViewPresentable) {
        if let presentable = presentable as? EnvironmentPropagator {
            presentable.insertEnvironmentObject(AnyViewCoordinator(self))
            presentable.insert(contentsOf: environmentInsertions)
        }
        
        if let presentable = presentable as? _opaque_AppKitOrUIKitViewCoordinatorBase {
            presentable.becomeChild(of: self)
        }
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: _opaque_AppKitOrUIKitViewCoordinatorBase) {
        if let parent = parent as? EnvironmentPropagator {
            parent.insertEnvironmentObject(AnyViewCoordinator(self))
        }
        
        insert(contentsOf: parent.environmentInsertions)
        
        for child in children {
            if let child = child as? _opaque_AppKitOrUIKitViewCoordinatorBase {
                child.becomeChild(of: self)
            }
        }
    }
    
    open func transition(for _: Route) -> ViewTransition {
        fatalError()
    }
    
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    @discardableResult
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, Error> {
        let publisher = triggerPublisher(for: route)
        let result = PassthroughSubject<ViewTransitionContext, Error>()
        
        publisher.subscribe(result, in: cancellables)
        
        return result.eraseToAnyPublisher()
    }
}
