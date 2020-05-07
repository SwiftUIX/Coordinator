//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension UIViewController {
    @usableFromInline
    var topmostPresentedViewController: UIViewController? {
        var topController = self
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }
    
    @usableFromInline
    var topmostViewController: UIViewController {
        topmostPresentedViewController ?? self
    }
}

#endif
