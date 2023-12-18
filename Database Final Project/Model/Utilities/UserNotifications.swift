//
//  UserNotifications.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/2/4.
//

import Foundation
import UserNotifications

class UserNotifications: NSObject {
    
    static let shared = UserNotifications()
    
    let content = UNMutableNotificationContent()
    
    /// 通知的識別碼
    /// - Tag: UserNotificationIdentifier
    enum UserNotificationIdentifier: String {
        
        /// 在 `設定 -> 備份／復原` 內執行 iCloud 備份
        case icloud
        
        /// iCloud 背景自動備份
        case icloudBackgroudAutomaticBackup
    }
    
    /// 建立通知
    /// - Parameters:
    ///   - identifier: [enum UserNotificationIdentifier](x-source-tag://UserNotificationIdentifier)，要移除通知的識別碼
    ///   - subTitle: 通知的副標題
    ///   - body: 通知的主體
    func add(identifier: UserNotificationIdentifier,
             subTitle: String,
             body: String) {
        content.title = AppDefine.appName
        content.subtitle = subTitle
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier.rawValue,
                                            content: content,
                                            trigger: trigger)
        
        Task {
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("建立通知成功！")
            } catch {
                print("建立通知失敗，Error：\(error.localizedDescription)")
            }
        }
    }
    
    /// 移除通知
    /// - Parameters:
    ///   - identifier: [enum UserNotificationIdentifier](x-source-tag://UserNotificationIdentifier)，要移除通知的識別碼
    func remove(identifier: UserNotificationIdentifier) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier.rawValue])
    }
}
