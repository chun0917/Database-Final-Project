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

            // App 是使用者自己點擊來開啟
            guard let windowScene = (scene as? UIWindowScene) else { return }
            let rootVC = MainViewController()
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
        print(UserPreferences.shared.isSignIn)
        removeBackgroundView()
        if  UserPreferences.shared.isSignIn {
            DispatchQueue.main.async {
                if let navigationController = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
//                    if !UserPreferences.shared.isLockTenMinutes {
//                        if navigationController.visibleViewController is LockAppViewController {
//                            let lockAppVC = LockAppViewController()
//                            lockAppVC.showReachabilityAlert()
//                        }
//                    }
                }
            }
        } else {
            // 當發生以上條件以外的情況，要將 App push 到 MainViewController
            DispatchQueue.main.async {
                if let navigationController = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
                    for controller in navigationController.viewControllers as Array<Any> {
                        if !(controller as AnyObject).isKind(of: MainViewController.self) {
                            // Navigation Stack 內沒有 MainViewController 的話，才 push 過去
                            navigationController.pushViewController(MainViewController(), animated: false)
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
    
    // MARK: - UIVisualEffectView
    
    var blurEffect = UIBlurEffect()
    var blurEffectView = UIVisualEffectView()

    // 加在 sceneWillResignActive、sceneDidEnterBackground
    func addVisualEffectView() {
        // 取得當前畫面的 UINavigationController
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController else {
            return
        }
        
        // 取得最上層的 UIViewController
        guard let topViewController = navigationController.visibleViewController else {
            return
        }
        
        let width = topViewController.view.frame.width
        let height = topViewController.view.frame.height
        
        blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame.size = CGSize(width: width, height: height)
        blurEffectView.tag = 100
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: blurEffectView.bounds.width/2, height: blurEffectView.bounds.height/2)
        blurEffectView.contentView.addSubview(imageView)
        
        topViewController.view.addSubview(blurEffectView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.leadingAnchor.constraint(equalTo: blurEffectView.safeAreaLayoutGuide.leadingAnchor, constant: 25)
        ])
    }

    // 加在 sceneDidBecomeActive
    func removeVisualEffectView() {
        // 取得當前畫面的 UINavigationController
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController else {
            return
        }
        
        // 取得最上層的 UIViewController
        guard let topViewController = navigationController.visibleViewController else {
            return
        }
        
        // 如果 blurEffectView 是屬於最上層的 UIViewController.view
        // 就將 blurEffectView 移除
        if blurEffectView.isDescendant(of: topViewController.view) {
            blurEffectView.removeFromSuperview()
            if let viewWithTag = topViewController.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
            }
        }
    }
}
