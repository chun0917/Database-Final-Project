import UIKit

@MainActor class BaseViewController: UIViewController {
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - typealias
    
    typealias ModalPresentationStyle = UIModalPresentationStyle
    typealias ModalTransitionStyle = UIModalTransitionStyle
    
    // MARK: - Variables
    
    /// 取得當前畫面的 UIViewController
    var topVisibleViewController: UIViewController? {
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController as? UINavigationController else {
            return nil
        }
        return navigationController.visibleViewController
    }
    
    /// 取得當前畫面的 UINavigationController
    var rootNavigationController: UINavigationController? {
        guard let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController as? UINavigationController else {
            return nil
        }
        return navigationController
    }
    
    // MARK: - UINavigationBar Style
    
    /// 設定 UINavigationBar 的外觀
    /// - Parameters:
    ///   - backgroundColor: navigationBar 的背景色
    ///   - tintColor: navigationBar 上 items 的色調顏色，預設為 UIColor.white
    ///   - foregroundColor: navigationBar 上的文字顏色，預設為 UIColor.white
    public func setupNavigationBarStyle(backgroundColor: UIColor,
                                        tintColor: UIColor = .white,
                                        foregroundColor: UIColor = .white) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.tintColor = tintColor
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : foregroundColor
        ]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - UITabBar Style
    
    /// 設定 UITabBar 的外觀
    public func setupTabBarStyle(tintColor: UIColor = .navigationBar) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        self.tabBarController?.tabBar.standardAppearance = appearance
        self.tabBarController?.tabBar.tintColor = tintColor
        self.tabBarController?.tabBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - NavigationController.present
    
    /// NavigationController.presentViewController 跳頁 (帶 Closure)
    /// - Parameters:
    ///   - viewController: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫，預設為 true
    ///   - isFullScreen: 是否全螢幕顯示，預設為 false
    ///   - completion: 換頁過程中，要做的事，預設為 nil
    public func presentViewController(viewController: UIViewController,
                                      animated: Bool = true,
                                      isFullScreen: Bool = false,
                                      completion: (() -> Void)? = nil) {
        let nvc = UINavigationController(rootViewController: viewController)
        nvc.modalPresentationStyle = (isFullScreen) ? .fullScreen : .automatic
        self.navigationController?.present(nvc, animated: animated, completion: completion)
    }
    
    // MARK: - NavigationController.push
    
    /// NavigationController.pushViewController 跳頁 (不帶 Closure)
    ///
    /// 一般常見的 self.navigationController.pushViewController
    ///
    /// - Parameters:
    ///   - nextVC: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫，預設為 true
    public func pushViewController(nextVC: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(nextVC, animated: animated)
    }
    
    /// NavigationController.pushViewController 跳頁 (不帶 Closure)
    ///
    /// 用 UIApplication.shared.connectScenes 裡面第一個是 keyWindow 的 rootViewController 來當作 UINavigationController，來進行 pushViewController
    ///
    /// - Parameters:
    ///   - viewController: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫，預設為 true
    public func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        if let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    /// NavigationController.pushViewController 跳頁 (帶 Closure)
    /// - Parameters:
    ///   - viewController: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func pushViewController(_ viewController: UIViewController,
                                   animated: Bool,
                                   completion: @escaping () -> Void) {
        self.navigationController?.pushViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    /// NavigationController.pushViewController 跳頁時刪掉舊的畫面 (不帶 Closure)
    /// - Parameters:
    ///   - currentVC: 現在的 UIViewController
    ///   - nextVC: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫
    public func pushViewController(currentVC: UIViewController,
                                   nextVC: UIViewController,
                                   animated: Bool) {
        navigationController?.pushViewController(nextVC, animated: true)

        guard self.navigationController != nil &&
                self.navigationController?.viewControllers != nil else {
            return
        }
        
        // 刪除上一個畫面
        let arrayVC = NSMutableArray(array: (self.navigationController?.viewControllers)!)
        for vc in arrayVC {
            if (vc as! UIViewController) == currentVC  {
                arrayVC.remove(vc)
                break
            }
        }
        
        self.navigationController?.viewControllers = arrayVC as! [UIViewController]
    }
    
    /// NavigationController.pushViewController 跳頁時刪掉舊的畫面 (帶 Closure)
    /// - Parameters:
    ///   - currentVC: 現在的 UIViewController
    ///   - nextVC: 要跳頁到的 UIViewController
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func pushViewController(currentVC: UIViewController,
                                   nextVC: UIViewController,
                                   animated: Bool,
                                   completion: @escaping () -> Void) {
        navigationController?.pushViewController(nextVC, animated: true)

        guard self.navigationController != nil &&
                self.navigationController?.viewControllers != nil else {
            return
        }
        
        // 刪除上一個畫面
        let arrayVC = NSMutableArray(array: (self.navigationController?.viewControllers)!)
        for vc in arrayVC {
            if (vc as! UIViewController) == currentVC  {
                arrayVC.remove(vc)
                break
            }
        }
        
        self.navigationController?.viewControllers = arrayVC as! [UIViewController]
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
    
    // MARK: - NavigationController.pop
    
    /// NavigationController.popViewController 回上一頁 (不帶 Closure)
    /// - Parameters:
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popViewController(_ animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    /// NavigationController.popViewController 回上一頁 (帶 Closure)
    /// - Parameters:
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func popViewController(animated: Bool, completion: @escaping () -> Void) {
        self.navigationController?.popViewController(animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    /// NavigationController.popToViewController 回到指定 ViewController (不帶 Closure)
    /// - Parameters:
    ///   - currentVC: 目前所在的 ViewController
    ///   - popVC_index: 在 NavigationController.viewControllers 中，指定 ViewController 的 index
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popToViewController(currentVC viewController: UIViewController,
                                    popVC_index: Int,
                                    animated: Bool = true) {
        guard let currentVC_index = navigationController?.viewControllers.firstIndex(of: self) else { return }
        if let vc = navigationController?.viewControllers[currentVC_index - popVC_index] {
            self.navigationController?.popToViewController(vc, animated: animated)
        }
    }
    
    /// NavigationController.popToViewController 回到指定 ViewController (不帶 Closure)
    ///
    /// 一般常見的 self.navigationController?.popToViewController
    ///
    /// - Parameters:
    ///   - viewController: 要 pop 回去的 ViewController
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popToViewController(_ viewController: UIViewController,
                                    animated: Bool = true) {
        self.navigationController?.popToViewController(viewController, animated: animated)
    }
    
    /// NavigationController.popToViewController 回到指定 ViewController (帶 Closure)
    /// - Parameters:
    ///   - viewController: 要 pop 回去的 ViewController
    ///   - animated: 是否要換頁動畫
    ///   - completion: 換頁過程中，要做的事
    public func popToViewController(_ viewController: UIViewController,
                                    animated: Bool,
                                    completion: @escaping () -> Void) {
        self.navigationController?.popToViewController(viewController, animated: animated)
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    /// NavigationController.popToRootViewController 回到 Root ViewController
    /// - Parameters:
    ///   - animated: 是否要換頁動畫，預設為 true
    public func popToRootViewController(_ animated: Bool = true) {
        self.navigationController?.popToRootViewController(animated: animated)
    }
    
    // MARK: - NavigationController.dismiss
    
    /// NavigationController.dismiss (帶 Closure)
    /// - Parameters:
    ///   - animated: 是否要關閉動畫，預設為 true
    ///   - completion: 關閉過程中，要做的事，預設為 nil
    public func dismissViewController(_ animated: Bool = true, completion: (()-> Void)? = nil) {
        self.navigationController?.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - ViewController.popUp
    
    /// ViewController.popUp (帶 Closure)
    /// - Parameters:
    ///   - viewController: 要彈出的 ViewController
    ///   - modalPresentationStyle: UIModalPresentationStyle，預設為 .overFullScreen
    ///   - modalTransitionStyle: UIModalTransitionStyle，預設為 .coverVertical
    ///   - animated: 是否要彈出動畫，預設為 true
    ///   - completion: 彈出過程中，要做的事，預設為 nil
    public func popUpViewController(viewController: UIViewController,
                                    modalPresentationStyle: ModalPresentationStyle = .overFullScreen,
                                    modalTransitionStyle: ModalTransitionStyle = .coverVertical,
                                    animated: Bool = true,
                                    completion: (()-> Void)? = nil) {
        viewController.modalPresentationStyle = modalPresentationStyle
        viewController.modalTransitionStyle = modalTransitionStyle
        self.present(viewController, animated: animated, completion: completion)
    }
    
    /// ViewController.dismissPopUp
    /// - Parameters:
    ///   - animated: 是否要關閉動畫，預設為 true
    ///   - completion: 關閉過程中，要做的事，預設為 nil
    public func dismissPopUpViewController(_ animated: Bool = true, completion: (()-> Void)? = nil) {
        self.dismiss(animated: animated, completion: completion)
    }
    
    /// 清除 NavigationStack 中除了下一個畫面以外的畫面
    /// - Parameters:
    ///   - viewController: 下一個畫面的 ViewController
    public func cleanViewControllers(viewController: UIViewController) {
        guard viewController.navigationController?.viewControllers != nil else {
            return
        }
        var vcs = viewController.navigationController!.viewControllers
        for _ in 0 ..< vcs.count - 1 {
            vcs.remove(at: 0)
        }
        DispatchQueue.main.async {
            viewController.navigationController!.viewControllers = vcs
        }
    }
    
    // MARK: - Create TabBarController
    
    /// 建立主畫面底下的 UITabBarController
    /// - Parameters:
    ///   - vcs: 要加入 TabBarController 的 Controller
    ///   - vcTitleArray: 各頁面的 Title 陣列
    ///   - imageNameArray: [[enum SFSymbols](x-source-tag://SFSymbols)]，各頁面 icon 的系統圖片名稱陣列
    ///   - modelPresentationStyle: 呈現樣式，預設為 UIModalPresentationStyle.fullScreen
    /// - Returns: 建立好的 UITabBarController
    public func createTabBarController(vcs: [UIViewController],
                                       vcTitleArray: [String],
                                       imageNameArray: [SFSymbols],
                                       modelPresentationStyle: ModalPresentationStyle = .fullScreen) -> UITabBarController {
        let tabBarVC = UITabBarController()
        
        let navVC1 = UINavigationController(rootViewController: vcs[0])
        let navVC2 = UINavigationController(rootViewController: vcs[1])
        let navVC3 = UINavigationController(rootViewController: vcs[2])
        
        navVC1.title = vcTitleArray[0]
        navVC2.title = vcTitleArray[1]
        navVC3.title = vcTitleArray[2]
        
        let navVCArray = [navVC1, navVC2, navVC3]
        
        tabBarVC.setViewControllers(navVCArray, animated: false)
        
        let tabBarTitleAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.navigationBar
        ]
        
        if let items = tabBarVC.tabBar.items {
            for x in 0 ..< items.count {
                items[x].image = UIImage(icon: imageNameArray[x])
                items[x].setTitleTextAttributes(tabBarTitleAttributes, for: .selected)
            }
        }
        
        tabBarVC.modalPresentationStyle = modelPresentationStyle
        
        return tabBarVC
    }
}
