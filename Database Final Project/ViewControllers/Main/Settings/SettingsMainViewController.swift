//
//  SettingsMainViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/1.
//

import UIKit

class SettingsMainViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    // MARK: - Variables
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startNotificationCenter()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupNavigationBarView()
        setupTabBarStyle()
        setupSettingsTableView()
    }
    
    /// 設定 TableView
    private func setupSettingsTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(SettingsMainTableViewCell.loadFromNib(),
                                   forCellReuseIdentifier: SettingsMainTableViewCell.identifier)
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: true,
                               backButtonImage: nil,
                               backButtonTitle: translate(.Settings),
                               displayMode: .noRightButtons)
    }
    
    // MARK: - Notification 監聽，裝置的 App AutoFill 是否開啟 func
    
    /// 偵測在 `設定 -> 密碼 -> 自動帶入密碼` 內，是否勾選 App App
    private func getAutoFillStatusInSettings() {
        AuthenticationManager.shared.getAutoFillStatusInSettings { status in
            if status {
                NotificationCenter.default.post(name: .statusAutoFill,
                                                object: nil,
                                                userInfo: ["status" : true])
            } else {
                NotificationCenter.default.post(name: .statusAutoFill,
                                                object: nil,
                                                userInfo: ["status" : false])
            }
        }
    }
    
    /// 設定頁自動帶入的 NotificationCenter
    private func startNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(statusAutoFillNotification(notification:)),
                                               name: .statusAutoFill,
                                               object: nil)
    }
    
    @objc func statusAutoFillNotification(notification: NSNotification) {
        let status = notification.userInfo?["status"] as! Bool
        DispatchQueue.main.async {
            if status {
                UserPreferences.shared.chooseAppToAutoFill = true
                // 已啟用自動填入服務
                Alert.showAlertWith(title: "",
                                    message: translate(.AutoFill_service_is_enabled),
                                    vc: self,
                                    confirmTitle: translate(.Confirm)) {
                    print("自動填寫密碼已勾選 App")
                }
            } else {
                UserPreferences.shared.chooseAppToAutoFill = false
                // 請選擇自動填入服務
                Alert.showAlertWith(title: "",
                                    message: translate(.Please_select_AutoFill_Service),
                                    vc: self,
                                    confirmTitle: translate(.Go_to_Settings),
                                    cancelTitle: translate(.Cancel),
                                    confirmActionStyle: .destructive) {
                    CommandBase.sharedInstance.openURL(with: AppDefine.SettingsURLScheme.Password.rawValue)
                } cancel: {
                    print("取消跳轉至「設定 -> 密碼 -> 自動填寫密碼」")
                }
            }
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension SettingsMainViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        //
    }
    
    func btnRightClicked(index: Int) {
        //
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDefine.Settings.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsMainTableViewCell.identifier,
                                                       for: indexPath) as? SettingsMainTableViewCell else {
            fatalError("SettingsMainTableViewCell 載入失敗")
        }
        switch AppDefine.Settings.allCases[indexPath.row] {
        default:
            cell.setupUI(imageName: AppDefine.Settings.allCases[indexPath.row].value.imageName,
                         title: AppDefine.Settings.allCases[indexPath.row].value.title,
                         switchState: false,
                         switchIsHidden: true)
        }
        return cell
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch AppDefine.Settings.allCases[indexPath.row] {
        case .autoFill:
            getAutoFillStatusInSettings()
        case .iCloudBackup:
            print("iCloud 備份")
            let nextVC = CKBackupRestoreViewController()
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        case .resetPassword:
            print("重設密碼")
            let nextVC = ResetPasswordViewController()
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        case .signOut:
            print("登出")
            if (UserPreferences.shared.isSignIn == true) {
                Alert.showToastWith(message: "登出成功", vc: self, during: .short, dismiss:  {
                    UserPreferences.shared.isSignIn = false
                    let nextVC = MainViewController()
                    self.pushViewController(nextVC, animated: true)
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch AppDefine.Settings.allCases[indexPath.row] {
        default:
            return 50
        }
    }
}
