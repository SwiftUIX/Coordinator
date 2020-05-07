//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

extension ViewTransition {
    @usableFromInline
    enum Payload {
        @usableFromInline
        typealias View = EnvironmentalAnyView
        
        case present(View)
        case replacePresented(with: View)
        case dismiss
        case dismissView(named: ViewName)
        
        case push(View)
        case pushOrPresent(View)
        case pop
        case popToRoot
        case popOrDismiss
        
        case set(View)
        case setRoot(View)
        case setNavigatable(View)
        
        case linear([ViewTransition])
        
        case dynamic(() -> AnyPublisher<ViewTransitionContext, ViewRouterError>)
        
        case none
    }
}

extension ViewTransition.Payload {
    @usableFromInline
    var view: EnvironmentalAnyView? {
        get {
            switch self {
                case .present(let view):
                    return view
                case .replacePresented(let view):
                    return view
                case .dismiss:
                    return nil
                case .dismissView:
                    return nil
                case .push(let view):
                    return view
                case .pushOrPresent(let view):
                    return view
                case .pop:
                    return nil
                case .popToRoot:
                    return nil
                case .popOrDismiss:
                    return nil
                case .set(let view):
                    return view
                case .setRoot(let view):
                    return view
                case .setNavigatable(let view):
                    return view
                case .linear:
                    return nil
                case .dynamic:
                    return nil
                case .none:
                    return nil
            }
        } set {
            guard let newValue = newValue else {
                return
            }
            
            switch self {
                case .present:
                    self = .present(newValue)
                case .replacePresented:
                    self = .replacePresented(with: newValue)
                case .dismiss:
                    break
                case .dismissView:
                    break
                case .push:
                    self = .push(newValue)
                case .pushOrPresent:
                    self = .pushOrPresent(newValue)
                case .pop:
                    break
                case .popToRoot:
                    break
                case .popOrDismiss:
                    break
                case .set:
                    self = .set(newValue)
                case .setRoot:
                    self = .setRoot(newValue)
                case .setNavigatable:
                    self = .setNavigatable(newValue)
                case .linear:
                    break
                case .dynamic:
                    break
                case .none:
                    break
            }
        }
    }
}
