//
// Copyright (c) Vatsal Manot
//

import Merge
import Foundation
import SwiftUIX

public enum _WindowSetTransition {
    case _appKitOrUIKitBlockAnimation(AppKitOrUIKitView.AnimationOptions, duration: Double)
}

extension ViewTransition {
    @usableFromInline
    enum Payload {
        case present(AnyPresentationView)
        case replace(with: AnyPresentationView)
        case dismiss
        case dismissView(named: AnyHashable)
        
        case push(AnyPresentationView)
        case pushOrPresent(AnyPresentationView)
        case pop
        case popToRoot
        case popOrDismiss
        case popToRootOrDismiss
        
        case set(AnyPresentationView, transition: _WindowSetTransition?)
        case setRoot(AnyPresentationView)
        
        case linear([ViewTransition])
        
        case custom(() -> AnyPublisher<ViewTransitionContext, Swift.Error>)
        
        case none
    }
}

extension ViewTransition.Payload {
    @usableFromInline
    var view: AnyPresentationView? {
        get {
            switch self {
                case .present(let view):
                    return view
                case .replace(let view):
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
                case .popToRootOrDismiss:
                    return nil
                case .set(let view, _):
                    return view
                case .setRoot(let view):
                    return view
                case .linear:
                    return nil
                case .custom:
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
                case .replace:
                    self = .replace(with: newValue)
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
                case .popToRootOrDismiss:
                    break
                case .set(_, let transition):
                    self = .set(newValue, transition: transition)
                case .setRoot:
                    self = .setRoot(newValue)
                case .linear:
                    break
                case .custom:
                    break
                case .none:
                    break
            }
        }
    }
}
