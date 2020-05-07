//
// Copyright (c) Vatsal Manot
//

import Merge
import SwiftUIX

open class OpaqueBaseViewCoordinator: DynamicViewPresentable {
    public static var _runtimeLookupCache: [ObjectIdentifier: Unmanaged<OpaqueBaseViewCoordinator>] = [:]
    
    public let cancellables = Cancellables()
    
    open var environmentBuilder = EnvironmentBuilder()
    
    open var name: ViewName? {
        return nil
    }
    
    open internal(set) var presenter: DynamicViewPresenter?
    open internal(set) var children: [DynamicViewPresentable] = []
    
    public init() {
        Self._runtimeLookupCache[ObjectIdentifier(Self.self)] = Unmanaged.passUnretained(self)
    }
    
    deinit {
        Self._runtimeLookupCache[ObjectIdentifier(Self.self)] = nil
    }
    
    func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        
    }
}

open class BaseViewCoordinator<Route: ViewRoute>: OpaqueBaseViewCoordinator, ViewCoordinator {
    @inlinable
    public func insertEnvironmentObject<B: ObservableObject>(_ bindable: B) {
        environmentBuilder.insert(bindable)
        
        children.forEach({
            ($0 as? EnvironmentProvider)?.insertEnvironmentObject(bindable)
        })
    }
    
    @inlinable
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) {
        environmentBuilder.merge(builder)
        
        children.forEach({
            ($0 as? EnvironmentProvider)?.mergeEnvironmentBuilder(builder)
        })
    }
    
    open func addChild(_ presentable: DynamicViewPresentable) {
        (presentable as? DynamicViewPresenter)?.insertEnvironmentObject(AnyViewCoordinator(self))
        (presentable as? EnvironmentProvider)?.mergeEnvironmentBuilder(environmentBuilder)
        
        (presentable as? OpaqueBaseViewCoordinator)?.becomeChild(of: self)
        
        children.append(presentable)
    }
    
    override open func becomeChild(of parent: OpaqueBaseViewCoordinator) {
        presenter = parent as? DynamicViewPresenter // FIXME!!!
        
        (parent as? EnvironmentProvider)?.insertEnvironmentObject(AnyViewCoordinator(self))
        
        mergeEnvironmentBuilder(parent.environmentBuilder)
        
        children.forEach({ ($0 as? OpaqueBaseViewCoordinator)?.becomeChild(of: self) })
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
