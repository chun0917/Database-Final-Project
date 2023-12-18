//
//  AppDefine.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/12/23.
//

import Foundation

struct AppDefine {

    /// App Groups Identifier
    static let appGroupsIdentifier = "group.final.project"
    
    /// 目前的 App 版號
    static var buildVersion: String {
        let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        return versionName + "(\(versionCode))"
    }
    
    ///  App 名稱
    static var appName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as! String
    }
    
    // MARK: - enum MarketingPage
    
    enum MarketingPage: Int, CaseIterable {
        case pageOne = 0, pageTwo, pageThree
        
        /// 需使用 `UIImage(named:)` 來取得圖片
        var imageName: String {
            switch self {
            case .pageOne:
                return "init_cert_intro_1"
            case .pageTwo:
                return "init_cert_intro_2"
            case .pageThree:
                return "init_cert_intro_3"
            }
        }
        
        var title: String {
            switch self {
            case .pageOne:
                return "高強度密碼"
            case .pageTwo:
                return "去中心化的儲存帳密"
            case .pageThree:
                return "自動填入服務"
            }
        }
        
        var subTitle: String {
            switch self {
            case .pageOne:
                return "為避免維持一貫簡單的密碼，請善用高強度密碼產生器，此自動產生各式大小寫字母、數字、特殊符號的隨機密碼，建立強大、安全與隨機的高強度密碼帶給您終極的防護。"
            case .pageTwo:
                return "請在「設定」開啟「自動備份」連結您的 Apple ID 帳號。\n以您的手機作為儲存中心，您儲存任何網址、帳號、密碼與加密貨幣錢包位置及註記詞。\n請善用儲存帳密備份機制，除了你自己，其他人無法解密，我們並無保留您的任何資料。\n或是您可手寫紙本紀錄存放實體保險箱內作為備份。"
            case .pageThree:
                return "請在「設定」開啟「自動填入服務」功能。\n提供瀏覽器與 App 的使用者名稱與密碼自動填入，有助於為您節省時間並防止輸入錯誤。"
            }
        }
    }
    
    // MARK: - typelias SettingsType、enum Settings

    typealias SettingsType = (imageName: SFSymbols, title: String)
    enum Settings: Int, CaseIterable {
        case autoFill = 0, iCloudBackup, resetPassword,signOut

        var value: SettingsType {
            switch self {
            case .autoFill:
                return (.settings, translate(.Enable_AutoFill_Services))
            case .iCloudBackup:
                return (.icloud, translate(.BackupRestore))
            case .resetPassword:
                return (.person, translate(.Change_Password))
            case .signOut:
                return (.rightChevronWithBackground, translate(.Sign_Out))
            }
        }
    }
    
    // MARK: - enum Store
    
    /// enum 商店頁面分類
    enum Store: Int, CaseIterable {
        case consumable = 0, options
    }
    
    /// enum 商店選項
    enum StoreOptions: Int, CaseIterable {
        case showManageSubscriptions = 0, getAllTransaction
        
        var title: String {
            switch self {
            case .showManageSubscriptions:
                return "查看 App Store 訂閱狀態"
            case .getAllTransaction:
                return "取得消耗性產品的最新交易紀錄"
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .showManageSubscriptions:
                return "查看"
            case .getAllTransaction:
                return "讀取"
            }
        }
    }
    
    // MARK: - enum iCloud Backup、Restore
    
    /// enum 備份／復原頁面分類
    enum CKBackupRestore: Int, CaseIterable {
        case cloudStatus = 0, backup, deleteRestore, backgroundRefresh
    }
    
    /// enum 備份選項
    enum CKBackupOptions: Int, CaseIterable {
        case backup = 0, chooseBackupInterval
    }
    
    /// enum 刪除、復原選項
    enum CKDeleteRestoreOptions: Int, CaseIterable {
        case delete = 0, restore
    }
    
    // MARK: - PasswordMainTableViewCell、NotesMainTableViewCell Menu Options
    
    /// PasswordMainTableViewCell、NotesMainTableViewCell Menu 選項
    enum MainMoreButtonMenu {
        
        /// 詳細資料
        case detail
        
        /// 刪除
        case delete
    }
    
    // MARK: - Automatic iCloud Backup TimeInterval Options
    
    typealias AutomaticBackupIntervalType = (title: String, interval: Int)
    enum AutomaticBackupInterval: Int, CaseIterable {
        #if DEBUG
        case fifteenMins = 0, halfHour, hour, twoHours, threeHour, never
        #else
        case day = 0, threeDay, week, twoWeek, month, never
        #endif
        
        #if DEBUG
        static var title: [String] = ["15 分鐘", "30 分鐘", "一小時", "兩小時", "三小時", "永不"]
        #else
        static var title: [String] = ["每天", "每三天", "每週", "每兩週", "每月", "永不"]
        #endif
        
        var interval: Int {
            switch self {
            #if DEBUG
            case .fifteenMins:
                return 15 * 60
            case .halfHour:
                return 30 * 60
            case .hour:
                return 1 * 60 * 60
            case .twoHours:
                return 2 * 60 * 60
            case .threeHour:
                return 3 * 60 * 60
            case .never:
                return 0
            #else
            case .day:
                return 24 * 60 * 60
            case .threeDay:
                return 24 * 3 * 60 * 60
            case .week:
                return 24 * 7 * 60 * 60
            case .twoWeek:
                return 24 * 14 * 60 * 60
            case .month:
                return 24 * 30 * 60 * 60
            case .never:
                return 0
            #endif
            }
        }
    }
    
    // MARK: - enum SettingsURLScheme
    
    enum SettingsURLScheme: String {
        
        // MARK: 設定
        
        /// 設定
        case Settings = "App-prefs:Settings"
        
        /// 設定 → 飛航模式
        case AirplaneMode = "App-prefs:AIRPLANE_MODE"
        
        /// 設定 → Wi-Fi
        case WiFi = "App-prefs:WIFI"
        
        /// 設定 → 藍牙
        case Bluetooth = "App-prefs:Bluetooth"
        
        /// 設定 → 個人熱點
        case InternetTethering = "App-prefs:INTERNET_TETHERING"
        
        /// 設定 → 通知
        case Notifications = "App-prefs:NOTIFICATIONS_ID"
        
        /// 設定 → 聲音與觸覺回饋
        case Sounds = "App-prefs:Sounds"
        
        /// 設定 → 聲音與觸覺回饋 → 鈴聲
        case Ringtone = "App-prefs:Sounds&path=Ringtone"
        
        /// 設定 → 勿擾模式
        case DonotDisturb = "App-prefs:DO_NOT_DISTURB"
        
        /// 設定 → 螢幕顯示與亮度 → 自動鎖定
        case AutoLock = "App-prefs:General&path=AUTOLOCK"
        
        /// 設定 → 背景圖片
        case Wallpaper = "App-prefs:Wallpaper"
        
        /// 設定 → Touch ID 與密碼／Face ID 與密碼
        case Passcode = "App-prefs:PASSCODE"
        
        /// 設定 → App Store
        case AppStore = "App-prefs:STORE"
        
        /// 設定 -> 密碼
        case Password = "App-prefs:PASSWORDS"
        
        /// 設定 → 備忘錄
        case Notes = "App-prefs:NOTES"
        
        /// 設定 → 電話
        case Phone = "App-prefs:Phone"
        
        /// 設定 → FaceTime
        case Facetime = "App-prefs:FACETIME"
        
        /// 設定 → 音樂
        case Music = "App-prefs:MUSIC"

        /// 設定 → 照片
        case Photos = "App-prefs:Photos"
        
        // MARK: 設定 -> Apple ID
        
        /// 設定 → Apple ID → iCloud
        case iCloud = "App-prefs:CASTLE"
        
        /// 設定 → Apple ID → iCloud
        case iCloudStorageAndBackup = "App-prefs:CASTLE&path=STORAGE_AND_BACKUP"
        
        // MARK: 設定 -> 一般
        
        /// 設定 → 一般
        case General = "App-prefs:General"
        
        /// 設定 → 一般 → 關於本機
        case About = "App-prefs:General&path=About"
        
        /// 設定 → 一般 → 軟體更新
        case SoftwareUpdate = "App-prefs:General&path=SOFTWARE_UPDATE_LINK"
        
        /// 設定 → 一般 → 日期與時間
        case DateAndTime = "App-prefs:General&path=DATE_AND_TIME"
        
        /// 設定 → 一般 → 鍵盤
        case Keyboard = "App-prefs:General&path=Keyboard"
        
        /// 設定 → 一般 → 語言與地區
        case LanguageAndRegion = "App-prefs:General&path=INTERNATIONAL"
        
        /// 設定 → 一般 → 描述檔
        case ManagedConfigurationList = "App-prefs:General&path=ManagedConfigurationList"
        
        /// 設定 → 一般 → 重置
        case Reset = "App-prefs:General&path=Reset"
    }
}
