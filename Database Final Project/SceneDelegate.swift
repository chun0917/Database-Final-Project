//
//  SceneDelegate.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

            guard let windowScene = (scene as? UIWindowScene) else { return }
            let rootVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: rootVC)
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window?.windowScene = windowScene
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")
        (UIApplication.shared.delegate as! AppDelegate).scheduleBackgroundProcessing()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive")
        print("isSignIn:",UserPreferences.shared.isSignIn)
        removeBackgroundView()
        // 未登入就回登入畫面
        if  (UserPreferences.shared.isSignIn == false) {
            DispatchQueue.main.async {
                if let navigationController = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
                    for controller in navigationController.viewControllers as Array<Any> {
                        if !(controller as AnyObject).isKind(of: LoginViewController.self) {
                            // Navigation Stack 內沒有 MainViewController 的話，才 push 過去
                            navigationController.pushViewController(LoginViewController(), animated: false)
                        } else {
                            break
                        }
                    }
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("sceneWillResignActive")
        
        if UserPreferences.shared.isAddBackgroundView {
            self.addBackgroundView()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
        
        (UIApplication.shared.delegate as! AppDelegate).scheduleBackgroundProcessing()
        
        if UserPreferences.shared.isAddBackgroundView {
            self.addBackgroundView()
        }
    }
    
    // MARK: - BackgroundView
    
    let container = UIView()
    
    func addBackgroundView() {
        container.tag = 516
        container.frame = UIScreen.main.bounds
        container.backgroundColor = .white
        
        self.window?.addSubview(container)
    }
    
    func removeBackgroundView() {
        container.removeFromSuperview()
        if let viewWithTag = self.window?.viewWithTag(516) {
            viewWithTag.removeFromSuperview()
        }
    }
}
