//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension UIViewController {
    var topmostPresentedViewController: UIViewController? {
        var topController = self
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }
    
    var topmostViewController: UIViewController {
        topmostPresentedViewController ?? self
    }
}

#endif
