//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class OpaqueBaseViewCoordinator: DynamicViewPresentable {
    public static var _runtimeLookup: [ObjectIdentifier: Unmanaged<OpaqueBaseViewCoordinator>] = [:]
    
    public let cancellables = Cancellables()
    
    open var environmentBuilder = EnvironmentBuilder()
    
    open var presentationName: ViewName? {
        return nil
    }
    
    open internal(set) var presenter: DynamicViewPresenter?
    open internal(set) var children: [DynamicViewPresentable] = []
    
    public init() {
        Self._runtimeLookup[ObjectIdentifier(Self.self)] = Unmanaged.passUnretained(self)
    }
    
    deinit {
        Self._runtimeLookup[ObjectIdentifier(Self.self)] = nil
    }
    
    func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        
    }
}

open class BaseViewCoordinator<Route: ViewRoute>: OpaqueBaseViewCoordinator, ViewCoordinator {
    @inlinable
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
        
        for child in children {
            if let child = child as? EnvironmentProvider {
                child.insertEnvironmentObject(bindable)
            }
        }
    }
    
    @inlinable
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) {
        environmentBuilder.merge(builder)
        
        for child in children {
            if let child = child as? EnvironmentProvider {
                child.mergeEnvironmentBuilder(builder)
            }
        }
    }
    
    open func addChild(_ presentable: DynamicViewPresentable) {
        if let presentable = presentable as? DynamicViewPresenter {
            presentable.insertEnvironmentObject(AnyViewCoordinator(self))
        }
        
        if let presentable = presentable as? EnvironmentProvider {
            presentable.mergeEnvironmentBuilder(environmentBuilder)
        }
        
        if let presentable = presentable as? OpaqueBaseViewCoordinator {
            presentable.becomeChild(of: self)
        }
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        presenter = parent as? DynamicViewPresenter // FIXME!!!
        
        if let parent = parent as? EnvironmentProvider {
            parent.insertEnvironmentObject(AnyViewCoordinator(self))
        }
        
        mergeEnvironmentBuilder(parent.environmentBuilder)
        
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
    public func triggerPublisher(for route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        Empty().eraseToAnyPublisher()
    }
    
    @discardableResult
    @inlinable
    public func trigger(_ route: Route) -> AnyPublisher<ViewTransitionContext, ViewRouterError> {
        let publisher = triggerPublisher(for: route)
        let result = PassthroughSubject<ViewTransitionContext, ViewRouterError>()
        
        publisher.subscribe(result, storeIn: cancellables)
        
        return result.eraseToAnyPublisher()
    }
    
    @inlinable
    public func parent<R, C: BaseViewCoordinator<R>>(ofType type: C.Type) -> C? {
        presenter as? C
    }
}
