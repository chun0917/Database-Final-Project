//
//  CKBackupRestoreViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/20.
//

import UIKit
import ProgressHUD

class CKBackupRestoreViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var reductionTableView: UITableView!
    
    // MARK: - Variables

    /// For CloudKitDatabase Add 資料用的
    var passwordTable: [PasswordTable] = []
    
    /// For CloudKitDatabase Add 資料用的
    var notesTable: [NotesTable] = []
    
    /// App 的 iCloud 是否可以存取
    var iCloudAvailable: Bool = false
    
    /// 使用者上一次備份到 iCloud 的時間字串
    var iCloudBackupLastTime: String = "-"
    
    /// iCloud 上是否存在備份資料
    var iCloudDataIsExist: Bool = false

    /// 使用者選擇的自動備份的選項
    var automaticBackupTitle: String = ""
    
    /// App 的「背景 App 重新整理」是否已開啟，預設為已開啟
    var backgroundRefreshStatus: Bool = true

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAccout() // 檢查使用者的 iCloud 帳號狀態
        checkDataIsExist() // 檢查 CloudKitDatabase 內是否有備份資料
        setupUI()
        setupNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
        DispatchQueue.global().async {
            self.fetchDataFromDatabase()
        }
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        // 設定 NavigationBar 樣式
        setupNavigationBarView()
        
        setupTableView()
        
        setupiCloudBackupLastTime(timestamp: UserPreferences.shared.iCloudBackupLastTimestamp)
        
        setupAutomaticBackupTitle()
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.BackupRestore),
                               displayMode: .noRightButtons)
    }
    
    /// 設定 UITableView 樣式
    private func setupTableView() {
        reductionTableView.delegate = self
        reductionTableView.dataSource = self
        reductionTableView.register(BackupHeaderTableViewCell.loadFromNib(),
                                    forCellReuseIdentifier: BackupHeaderTableViewCell.identifier)
        reductionTableView.register(BackupOperationTableViewCell.loadFromNib(),
                                    forCellReuseIdentifier: BackupOperationTableViewCell.identifier)
        reductionTableView.register(BackupTableViewCell.loadFromNib(),
                                    forCellReuseIdentifier: BackupTableViewCell.identifier)
    }
    
    /// 設定 `自動備份` 的字眼
    private func setupAutomaticBackupTitle() {
        switch UserPreferences.shared.iCloudAutomaticBackupInterval {
        #if DEBUG
        case 15 * 60:
            // 15 分鐘
            automaticBackupTitle = translate(.minutes15)
        case 30 * 60:
            // 30 分鐘
            automaticBackupTitle = translate(.minutes30)
        case 1 * 60 * 60:
            // 一小時
            automaticBackupTitle = translate(.hour1)
        case 2 * 60 * 60:
            // 兩小時
            automaticBackupTitle = translate(.hours2)
        case 3 * 60 * 60:
            // 三小時
            automaticBackupTitle = translate(.hours3)
        #else
        case 24 * 60 * 60:
            // 每天
            automaticBackupTitle = translate(.everyday)
        case 24 * 3 * 60 * 60:
            // 每三天
            automaticBackupTitle = translate(.every3days)
        case 24 * 7 * 60 * 60:
            // 每週
            automaticBackupTitle = translate(.everyweek)
        case 24 * 14 * 60 * 60:
            // 每兩週
            automaticBackupTitle = translate(.every2weeks)
        case 24 * 30 * 60 * 60:
            // 每月
            automaticBackupTitle = translate(.everymonth)
        #endif
        case 0:
            // 永不
            automaticBackupTitle = translate(.never)
        default:
            automaticBackupTitle = translate(.Close)
        }
    }
    
    /// 設定 `上一次備份到 iCloud` 的 UILabel 樣式
    private func setupiCloudBackupLastTime(timestamp: Int64) {
        if timestamp != 0 {
            iCloudBackupLastTime = CommandBase.sharedInstance.dateformatter(timestamp: timestamp,
                                                                            needFormat: "YYYY/MM/dd HH:mm:ss")
        }
    }
    
    // MARK: - Function
    
    /// 設定 NotificationCenter.default.addObserver
    private func setupNotificationObserver() {
        // 監聽 App 的 iCloud 存取狀態改變
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ckAccountStatusChanged),
                                               name: .CKAccountChanged,
                                               object: nil)
        
        // 監聽 App 的背景 App 重新整理存取狀態改變
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backgroundRefreshStatusChanged),
                                               name: UIApplication.backgroundRefreshStatusDidChangeNotification,
                                               object: nil)
    }
    
    /// 從 LocalDatabase 內撈取要備份的密碼、記事資料
    private func fetchDataFromDatabase() {
        passwordTable = LocalDatabase.shared.fetchToCloud(table: .password)
        notesTable = LocalDatabase.shared.fetchToCloud(table: .note)
        print(passwordTable)
        
    }
    
    /// 檢查 CloudKitDatabase 內是否有備份資料
    private func checkDataIsExist() {
        Task {
            do {
                let isExist = try await CloudKitDatabase.shared.checkCKDatabaseDataIsExist()
                iCloudDataIsExist = isExist
            } catch (let error as CloudKitDatabase.CKDatabaseError) {
                Alert.showAlertWithError(message: "\(error)",
                                         vc: self,
                                         confirmTitle: translate(.Confirm))
            }
        }
    }
    
    /// 檢查使用者的 iCloud 帳號狀態
    private func checkAccout() {
        Task {
            do {
                let status = try await CloudKitDatabase.shared.checkCKAccountStatus()
                iCloudAvailable = (status == .available) ? true : false
                await MainActor.run {
                    self.reductionTableView.reloadData()
                }
            } catch {
                Alert.showAlertWithError(message: "CKAccount Status Error：" + error.localizedDescription,
                                         vc: self,
                                         confirmTitle: translate(.Confirm))
            }
        }
    }
    
    // MARK: - Notification CKAccountStatus Changed Function
    
    @objc func ckAccountStatusChanged() {
        print("使用者的 iCloud 狀態有改變")
        checkAccout()
    }
    
    // MARK: - Notification UIApplication.shared.backgroundRefreshStatus Changed Function
    
    @objc func backgroundRefreshStatusChanged() {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .restricted, .denied:
            print("使用者未開啟「背景 App 重新整理」")
            backgroundRefreshStatus = false
            DispatchQueue.main.async {
                self.reductionTableView.reloadData()
            }
        case .available:
            print("使用者已開啟「背景 App 重新整理」")
            backgroundRefreshStatus = true
            DispatchQueue.main.async {
                self.reductionTableView.reloadData()
            }
        @unknown default:
            break
        }
    }
    
    func iCloudUnAvailableAlert() {
        Alert.showAlertWithError(message: translate(.User_has_not_enabled_iCloud_access_for_iCloud_Drive_and_App_in_settings),
                                 vc: self,
                                 confirmTitle: translate(.Close)) {
            Alert.showAlertWith(title: translate(.Whether_to_go_to_the_settings_to_open),
                                message: nil,
                                vc: self,
                                confirmTitle: translate(.Go_to_Settings),
                                cancelTitle: translate(.Cancel),
                                confirmActionStyle: .destructive) {
                CommandBase.sharedInstance.openURL(with: AppDefine.SettingsURLScheme.iCloud.rawValue)
            } cancel: {
                print("使用者取消前往「設定 -> iCloud」內開啟 iCloud 雲碟與 App 的 iCloud 存取權限")
            }
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension CKBackupRestoreViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        popViewController()
    }
    
    func btnRightClicked(index: Int) {
        //
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CKBackupRestoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if backgroundRefreshStatus == true {
            return AppDefine.CKBackupRestore.allCases.count - 1
        } else {
            return AppDefine.CKBackupRestore.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AppDefine.CKBackupRestore.allCases[section] {
        case .cloudStatus:
            return 1
        case .backup:
            return 2
        case .deleteRestore:
            return 2
        case .backgroundRefresh:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch AppDefine.CKBackupRestore.allCases[indexPath.section] {
        case .cloudStatus:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BackupHeaderTableViewCell.identifier) as? BackupHeaderTableViewCell else {
                fatalError("BackupHeaderTableViewCell 載入失敗")
            }
            
            cell.setInit(iCloudAvailable: iCloudAvailable,
                         backupTime: String.localizedStringWithFormat(translate(.Last_backup_time), iCloudBackupLastTime))
            
            cell.selectionStyle = .none // 讓 Cell 不能點擊
            
            return cell
        case .backup:
            guard let backupOperationCell = tableView.dequeueReusableCell(withIdentifier: BackupOperationTableViewCell.identifier) as? BackupOperationTableViewCell else {
                fatalError("BackupOperationTableViewCell 載入失敗")
            }
      
            switch AppDefine.CKBackupOptions.allCases[indexPath.row] {
            case .backup:
                backupOperationCell.setInit(backupTitle: translate(.Backup_to_iCloud),
                                            automaticBackupIntervalTitle: "",
                                            statusIsHidden: true)
                return backupOperationCell
            case .chooseBackupInterval:
                backupOperationCell.setInit(backupTitle: translate(.Automatic_Backup),
                                            automaticBackupIntervalTitle: automaticBackupTitle,
                                            statusIsHidden: false)
                return backupOperationCell
            }
        case .deleteRestore:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BackupTableViewCell.identifier) as? BackupTableViewCell else {
                fatalError("BackupTableViewCell 載入失敗")
            }
            switch AppDefine.CKDeleteRestoreOptions.allCases[indexPath.row] {
            case .delete:
                cell.setInit(title: translate(.Delete_Backup_Data), color: .red)
                return cell
            case .restore:
                cell.setInit(title: translate(.Restore), color: .black)
                return cell
            }
        case .backgroundRefresh:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BackupTableViewCell.identifier) as? BackupTableViewCell else {
                fatalError("BackupTableViewCell 載入失敗")
            }
            cell.setInit(title: "「背景 App 重新整理」尚未開啟", color: .red)
            return cell
        }
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch AppDefine.CKBackupRestore.allCases[indexPath.section] {
        case .cloudStatus:
            break
        case .backup:
            switch AppDefine.CKBackupOptions.allCases[indexPath.row] {
            case .backup:
                // 備份至 iCloud
                if iCloudAvailable {
                    Alert.showAlertWith(title: translate(.Backup_Data),
                                        message: translate(.If_there_is_a_previous_backup_this_operation_will_overwrite_all_App_data_currently_stored_in_iCloud_Do_you_want_to_backup),
                                        vc: self,
                                        confirmTitle: translate(.Backup),
                                        cancelTitle: translate(.Cancel),
                                        confirm: { [unowned self] in
                        ProgressHUD.show(translate(.Backing_up))
                        
                        Task {
                            do {
                                try await CloudKitDatabase.shared.backup(password: passwordTable, notes: notesTable)
                                print("密碼與記事資料皆已備份至 iCloud 上！")
                                UserPreferences.shared.iCloudBackupLastTimestamp = Int64(Date().timeIntervalSince1970)
                                setupiCloudBackupLastTime(timestamp: UserPreferences.shared.iCloudBackupLastTimestamp)
                                await MainActor.run {
                                    ProgressHUD.showSucceed(translate(.Backup_Successful))
                                    reductionTableView.reloadData()
                                }
                                UserNotifications.shared.remove(identifier: .icloud)
                                UserNotifications.shared.add(identifier: .icloud,
                                                             subTitle: "iCloud \(translate(.Backup))，\(translate(.Backup_Successful))",
                                                             body: "當前時間：\(self.iCloudBackupLastTime)")
                            } catch (let error as CloudKitDatabase.CKDatabaseError) {
                                #if DEBUG
                                print("Backup 1：", error)
                                #endif
                                ProgressHUD.dismiss()
                                Alert.showAlertWithError(message: "Backup Failed！\nError：\(error)",
                                                         vc: self,
                                                         confirmTitle: translate(.Close))
                            }
                        }
                    })
                } else {
                    iCloudUnAvailableAlert()
                }
            case .chooseBackupInterval:
                // 自動備份
                let message = """
                \(translate(.iCloud_automatic_backup_in_background_info_description1))
                \(translate(.iCloud_automatic_backup_in_background_info_description2))\n
                1. \(translate(.iCloud_automatic_backup_in_background_info_part1))\n
                2. \(translate(.iCloud_automatic_backup_in_background_info_part2))\n
                3. \(translate(.iCloud_automatic_backup_in_background_info_part3))\n
                4. \(translate(.iCloud_automatic_backup_in_background_info_part4))
                """
                Alert.showActionSheetWith(title: translate(.iCloud_automatic_backup_in_background) + translate(.Info),
                                          message: message,
                                          isLeftAlign: true,
                                          options: AppDefine.AutomaticBackupInterval.title,
                                          vc: self) { index in
                    self.automaticBackupTitle = AppDefine.AutomaticBackupInterval.title[index]
                    UserPreferences.shared.iCloudAutomaticBackupInterval = AppDefine.AutomaticBackupInterval.allCases[index].interval
                    print("iCloudAutomaticBackupInterval：", UserPreferences.shared.iCloudAutomaticBackupInterval)
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }
        case .deleteRestore:
            switch AppDefine.CKDeleteRestoreOptions.allCases[indexPath.row] {
            case .delete:
                // 刪除備份資料
                if iCloudAvailable {
                    if iCloudDataIsExist {
                        Alert.showAlertWith(title: translate(.Delete_Backup_Data),
                                            message: translate(.All_backup_data_stored_in_your_iCloud_will_be_deleted_Do_you_want_to_continue),
                                            vc: self,
                                            confirmTitle: translate(.Delete),
                                            cancelTitle: translate(.Cancel),
                                            confirm: {
                            ProgressHUD.show(translate(.Deleting_backup_data))
                            
                            Task {
                                do {
                                    try await CloudKitDatabase.shared.delete()
                                    print("iCloud 上的備份資料皆已刪除完成")
                                    self.iCloudDataIsExist = false
                                    await MainActor.run {
                                        ProgressHUD.showSucceed(translate(.Backup_data_on_iCloud_has_been_deleted))
                                        self.iCloudBackupLastTime = "-"
                                        UserPreferences.shared.iCloudBackupLastTimestamp = 0
                                        self.reductionTableView.reloadData()
                                    }
                                } catch (let error as CloudKitDatabase.CKDatabaseError) {
                                    #if DEBUG
                                    print("Delete 1：", error)
                                    #endif
                                    ProgressHUD.dismiss()
                                    Alert.showAlertWithError(message: "Delete Backup Data Failed！\nError：\(error)",
                                                             vc: self,
                                                             confirmTitle: translate(.Close))
                                }
                            }
                        })
                    } else {
                        Alert.showAlertWith(title: translate(.Warnings),
                                            message: translate(.There_is_currently_no_backup_data_of_App_on_iCloud_Please_execute_Backup_to_iCloud_first_and_then_perform_this_operation),
                                            vc: self,
                                            confirmTitle: translate(.Close))
                    }
                } else {
                    iCloudUnAvailableAlert()
                }
            case .restore:
                // 復原
                if iCloudAvailable {
                    if iCloudDataIsExist {
                        Alert.showAlertWith(title: translate(.Restore_Backup_Data),
                                            message: translate(.All_App_data_currently_stored_on_the_device_will_be_overwritten_Do_you_want_to_restore_the_data),
                                            vc: self,
                                            confirmTitle: translate(.Restore),
                                            cancelTitle: translate(.Cancel),
                                            confirm: {
                            ProgressHUD.show(translate(.Restoring_backup_data))
                            
                            Task {
                                do {
                                    let result = try await CloudKitDatabase.shared.fetch()
                                    LocalDatabase.shared.deleteAll(table: .password)
                                    result.password.forEach { password in
                                        LocalDatabase.shared.insert(id: password.id, userID: UserPreferences.shared.userID, cipherText: password.cipherText, table: .password)
                                    }
                                    LocalDatabase.shared.deleteAll(table: .note)
                                    result.notes.forEach { notes in
                                        LocalDatabase.shared.insert(id: notes.id, userID: UserPreferences.shared.userID, cipherText: notes.cipherText, table: .note)
                                    }
                                    await MainActor.run {
                                        print("iCloud 上的備份資料皆已復原到本地完成")
                                        ProgressHUD.showSucceed(translate(.Backup_data_restored_successfully))
                                    }
                                } catch (let error as CloudKitDatabase.CKDatabaseError) {
                                    #if DEBUG
                                    print("Restore 1：", error)
                                    #endif
                                    ProgressHUD.dismiss()
                                    Alert.showAlertWithError(message: "Restore Backup Data Failed！\nError：\(error)",
                                                             vc: self,
                                                             confirmTitle: translate(.Close))
                                }
                            }
                        })
                    } else {
                        Alert.showAlertWith(title: translate(.Warnings),
                                            message: translate(.There_is_currently_no_backup_data_of_App_on_iCloud_Please_execute_Backup_to_iCloud_first_and_then_perform_this_operation),
                                            vc: self,
                                            confirmTitle: translate(.Close))
                    }
                } else {
                    iCloudUnAvailableAlert()
                }
            }
        case .backgroundRefresh:
            Alert.showAlertWith(title: translate(.Warnings),
                                message: translate(.Please_turn_on_the_Background_App_Refresh_function_of_App_to_perform_iCloud_background_automatic_backup_smoothly),
                                vc: self,
                                confirmTitle: translate(.Go_to_Settings),
                                cancelTitle: translate(.Cancel)) {
                CommandBase.sharedInstance.openURL(with: UIApplication.openSettingsURLString)
            } cancel: {
                Alert.showAlertWith(title: translate(.Warnings),
                                    message: translate(.If_you_do_not_enable_the_Background_App_Refresh_function_you_will_not_be_able_to_perform_iCloud_background_automatic_backup_Do_you_want_to_enable_it),
                                    vc: self,
                                    confirmTitle: translate(.Go_to_Settings),
                                    cancelTitle: translate(.Cancel)) {
                    CommandBase.sharedInstance.openURL(with: UIApplication.openSettingsURLString)
                } cancel: {
                    print("使用者取消前往設定開啟 App 的「背景 App 重新整理」功能")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch AppDefine.CKBackupRestore.allCases[indexPath.section] {
        case .cloudStatus:
            return 150
        case .backup, .deleteRestore, .backgroundRefresh:
            return 44
        }
    }
}
