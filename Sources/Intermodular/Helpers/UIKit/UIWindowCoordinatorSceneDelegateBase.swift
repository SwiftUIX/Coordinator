//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Combine
import SwiftUIX
import UIKit

open class UIWindowCoordinatorSceneDelegateBase<AppDelegate: UIApplicationDelegate, Coordinator: UIWindowCoordinatorProtocol>: UIResponder, UIWindowSceneDelegate {
    open var coordinator: Coordinator!
    
    open var initialRoute: Coordinator.Route? {
        return nil
    }
    
    @available(iOSApplicationExtension, unavailable)
    open var applicationDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        self.coordinator = Coordinator(window: UIWindow(windowScene: windowScene))
        
        if let initialRoute = initialRoute {
            coordinator.trigger(initialRoute)
        }
    }
    
    open func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    open func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    open func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    open func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    open func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}

#endif
