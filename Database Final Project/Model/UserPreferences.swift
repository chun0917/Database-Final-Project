//
//  UserPreferences.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/24.
//

import Foundation

class UserPreferences {
    
    static let shared = UserPreferences()
    
    private let userPreferences: UserDefaults
    
    private init() {
        userPreferences = UserDefaults(suiteName: AppDefine.appGroupsIdentifier)!
    }
    
    enum UserPreference: String {
        // MARK: User Information
        case email
        
        case phone
        
        case userID
        
        // MARK: General
        /// 是否登入
        case isSignIn
        
        /// 裝置的 App AutoFill 是否開啟
        case chooseAppToAutoFill
        
        /// 螢幕閒置的開始時間
        case idleStartTime
        
        /// 螢幕閒置的結束時間
        case idleEndTime
        
        /// 是否為首次新增密碼／記事
        case isFirstAddPasswordOrNotes
        
        /// 是否需要新增背景畫面
        case isAddBackgroundView
        
        
        // MARK: LocalDatabase
        
        /// 資料庫路徑
        case databasePath
        
        /// 新增／編輯資料時加密用的 privateKey
        case privateKeyForDatabase
        
        // MARK: iCloud Backup
        
        /// 上一次備份到 iCloud 的時間戳
        case iCloudBackupLastTimestamp
        
        /// 背景處理任務自動備份到 iCloud 的間隔
        case iCloudAutomaticBackupInterval
        
    }
    
    // MARK: - Variables
    // User Information
    var email: String {
        get { return userPreferences.string(forKey: UserPreference.email.rawValue) ?? "" }
        set { userPreferences.set(newValue, forKey: UserPreference.email.rawValue) }
    }
    var phone: Data{
        get { return userPreferences.data(forKey: UserPreference.phone.rawValue)! }
        set { userPreferences.set(newValue, forKey: UserPreference.phone.rawValue) }
    }
    var userID: String {
        get { return userPreferences.string(forKey: UserPreference.userID.rawValue) ?? "" }
        set { userPreferences.set(newValue, forKey: UserPreference.userID.rawValue) }
    }
    
    // General
    var isSignIn: Bool {
        get { return userPreferences.bool(forKey: UserPreference.isSignIn.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.isSignIn.rawValue) }
    }
    
    var chooseAppToAutoFill: Bool {
        get { return userPreferences.bool(forKey: UserPreference.chooseAppToAutoFill.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.chooseAppToAutoFill.rawValue) }
    }
    var idleStartTime: Date {
        get { return userPreferences.object(forKey: UserPreference.idleStartTime.rawValue) as! Date }
        set { userPreferences.set(newValue, forKey: UserPreference.idleStartTime.rawValue) }
    }
    var idleEndTime: Date {
        get { return userPreferences.object(forKey: UserPreference.idleEndTime.rawValue) as! Date }
        set { userPreferences.set(newValue, forKey: UserPreference.idleEndTime.rawValue) }
    }
    var isFirstAddPasswordOrNotes: Bool {
        get { return userPreferences.bool(forKey: UserPreference.isFirstAddPasswordOrNotes.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.isFirstAddPasswordOrNotes.rawValue) }
    }
    var isAddBackgroundView: Bool {
        get { return userPreferences.bool(forKey: UserPreference.isAddBackgroundView.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.isAddBackgroundView.rawValue) }
    }
    
    // LocalDatabase
    var databasePath: String {
        get { return userPreferences.string(forKey: UserPreference.databasePath.rawValue) ?? "" }
        set { userPreferences.set(newValue, forKey: UserPreference.databasePath.rawValue) }
    }
    var privateKeyForDatabase: String {
        get {
            let startIndex = UserPreferences.shared.phone.hexadecimal.startIndex
            var privateKey = ""
            for i in 0 ... 32 {
                let range: String.Index = UserPreferences.shared.phone.hexadecimal.index(startIndex, offsetBy: i)
                privateKey = String(UserPreferences.shared.phone.hexadecimal[..<range])
            }
            return privateKey
        }
    }
    
    // iCloud Backup
    var iCloudBackupLastTimestamp: Int64 {
        get { return Int64(userPreferences.integer(forKey: UserPreference.iCloudBackupLastTimestamp.rawValue)) }
        set { userPreferences.set(newValue, forKey: UserPreference.iCloudBackupLastTimestamp.rawValue) }
    }
    var iCloudAutomaticBackupInterval: Int {
        get { return userPreferences.integer(forKey: UserPreference.iCloudAutomaticBackupInterval.rawValue) }
        set { userPreferences.set(newValue, forKey: UserPreference.iCloudAutomaticBackupInterval.rawValue) }
    }
    
    
    // MARK: - Reset Initial Flow Variables
    
    func resetInitialFlowVarables() {
        UserPreferences.shared.iCloudBackupLastTimestamp = 0
        UserPreferences.shared.isFirstAddPasswordOrNotes = false
        UserPreferences.shared.isAddBackgroundView = false
    }
}
