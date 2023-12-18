//
//  AppDelegate.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/20.
//

import UIKit
import IQKeyboardManagerSwift
import os
import FirebaseCore
import FirebaseMessaging
import BackgroundTasks

//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let bgProcessTaskID = "com.final.project.icloudBackupInBackground"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("buildVersion：",AppDefine.buildVersion)
        
        LocalDatabase.shared.createTable()
        IQKeyboardManager.shared.enable = true // 啟用 IQKeyboardManagerSwift
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true // 點空白處關鍵盤
        IQKeyboardManager.shared.enableAutoToolbar = true // 顯示工具列
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidIdle10MinsAlert),
                                               name: .kApplicationDidIdle10MinsNotification,
                                               object: nil) // 監聽是否螢幕閒置 10 分鐘
        // 螢幕截圖
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTakeScreenshot(notification:)),
                                               name: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil)
        // 螢幕錄影
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(isRecording(notification:)),
                                               name: UIScreen.capturedDidChangeNotification,
                                               object: nil)
        
        FirebaseApp.configure()
        
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isAllowed, error in
            guard error == nil else {
                print("UNUserNotificationCenter.requestAuthorization Error：", error!.localizedDescription)
                return
            }
            
            if isAllowed {
                print("使用者同意接收通知")
            } else {
                print("使用者不同意接收通知")
            }
        }
        application.registerForRemoteNotifications()
        
        /* Firebase Cloud Messaging 設定 END */
        
        registerBackgroundProcessingTask(bgTaskID: bgProcessTaskID) // 註冊背景處理任務
        
        return true
    }
    
    @objc func applicationDidIdle10MinsAlert() {
        if UserPreferences.shared.isSignIn {
            if Date() >= UserPreferences.shared.idleEndTime {
                Logger().log("螢幕閒置 5mins，要將 App 上鎖！")
                DispatchQueue.main.async {
                    if let navigationController = UIApplication.shared
                        .connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?
                        .rootViewController as? UINavigationController {
                        navigationController.pushViewController(MainViewController(), animated: false)
                    }
                }
            } else {
                Logger().log("尚未到達螢幕閒置 5mins！")
            }
        } else {
            print("尚未登入，不處理螢幕閒置 5mins")
        }
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait // 螢幕鎖定直向
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - Detect Screenshots

extension AppDelegate {
    
    /// 螢幕截圖
    @objc func didTakeScreenshot(notification: Notification) {
        Logger().log("偵測到螢幕截圖！")
        if let navigationController = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController as? UINavigationController {
            Alert.showToastWith(message: translate(.Screenshot_detected),
                                vc: navigationController,
                                during: .long)
        }
    }
}

// MARK: - Detect Screen Recording

extension AppDelegate {
    
    /// 螢幕錄影
    @objc func isRecording(notification: Notification) {
        for screen in UIScreen.screens {
            if screen.isCaptured {
                Logger().log("偵測到螢幕錄影！")
                if let navigationController = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController as? UINavigationController {
                    Alert.showToastWith(message: translate(.Screen_recording_detected),
                                        vc: navigationController,
                                        during: .long)
                }
            }
        }
    }
}

// MARK: - Background Processing Task

extension AppDelegate {
    
    /// 註冊背景處理任務
    /// - Parameters:
    ///   - bgTaskID: 背景處理任務 ID
    func registerBackgroundProcessingTask(bgTaskID id: String) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: id,
                                        using: nil) { task in
            Logger().log("[BGTASK] Perform bg processing \(id)")
            self.handleBackgroundProcessingTask(task: task as! BGProcessingTask)
        }
    }
    
    /// 背景處理任務排程
    func scheduleBackgroundProcessing() {
        guard UserPreferences.shared.iCloudAutomaticBackupInterval > 0 else {
            return
        }
        
        let request = BGProcessingTaskRequest(identifier: bgProcessTaskID)
        
        // 要求執行背景處理任務要連接網路
        request.requiresNetworkConnectivity = true
        
        // 要求執行背景處理任務是否要接上電源
        // 給 false 的話，也不一定真的會在用電池的時候執行，一切都看系統來決定
        request.requiresExternalPower = true
        
        // 要求背景任務最早執行的時間，系統不會在此時間之前執行，但也不會準時在這時間後執行
        let earliestBeginDate = TimeInterval(UserPreferences.shared.iCloudAutomaticBackupInterval)
        request.earliestBeginDate = Date(timeIntervalSinceNow: earliestBeginDate)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule Background Processing Task, Error：\(error)")
        }
    }
    
    func handleBackgroundProcessingTask(task: BGProcessingTask) {
        Task {
            do {
                try await CloudKitDatabase.shared.backgroundProcessingTaskBackup()
                Logger().log("Background Processing Task - Automatic Backup to iCloud Succeed！")
                UserPreferences.shared.iCloudBackupLastTimestamp = Int64(Date().timeIntervalSince1970)
                let time = CommandBase.sharedInstance.dateformatter(timestamp: UserPreferences.shared.iCloudBackupLastTimestamp,
                                                                    needFormat: "YYYY/MM/dd HH:mm:ss")
                UserNotifications.shared.remove(identifier: .icloudBackgroudAutomaticBackup)
                UserNotifications.shared.add(identifier: .icloudBackgroudAutomaticBackup,
                                             subTitle: "iCloud 背景自動備份，備份成功！",
                                             body: "當前時間：\(time)")
                task.setTaskCompleted(success: true)
                self.scheduleBackgroundProcessing()
            } catch {
                Logger().log("Background Processing Task - Automatic Backup to iCloud Failed！, Error：\(error)")
                let failedTime = CommandBase.sharedInstance.dateformatter(timestamp: Int64(Date().timeIntervalSince1970),
                                                                          needFormat: "YYYY/MM/dd HH:mm:ss")
                UserNotifications.shared.remove(identifier: .icloudBackgroudAutomaticBackup)
                UserNotifications.shared.add(identifier: .icloudBackgroudAutomaticBackup,
                                             subTitle: "iCloud 背景自動備份，備份失敗！",
                                             body: "當前時間：\(failedTime)")
                task.setTaskCompleted(success: false)
            }
            
            task.expirationHandler = {
                Logger().log("Background Processing Task - expirationHandler！")
            }
        }
    }
}

// MARK: - RemoteNotification

extension AppDelegate {
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification：", userInfo)
        
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 當 App 在前景，推播出現時觸發
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        
        #if DEBUG
        print("willPresent.content.title：", content.title)
        print("willPresent.content.title：", content.subtitle)
        print("willPresent.content.message：", content.body)
        #endif
        
        completionHandler([.banner, .list, .sound]) // .banner -> 橫幅，.list -> 通知中心
    }
    
    // 當 App 在背景或是尚未啟動，使用者點選推播打開 App 時觸發
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        
        #if DEBUG
        print("didReceive.content.title：", content.title)
        print("didReceive.content.title：", content.subtitle)
        print("didReceive.content.message：", content.body)
        #endif
    }
}
