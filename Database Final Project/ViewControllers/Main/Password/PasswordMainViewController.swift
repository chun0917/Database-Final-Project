//
//  PasswordMainViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/1.
//

import UIKit

class PasswordMainViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var passwordTableView: UITableView!
    
    // MARK: - Variables
    
    var passwordModel: [PasswordModel] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserPreferences.shared.isAddBackgroundView = true
        
        setupUI()
        setupNotificationCenter()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 設定 tabBar 狀態
        self.tabBarController?.tabBar.isHidden = false
        
        DispatchQueue.global().async {
            self.fetchDataFromDatabase()
        }
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        // NavigationBar
        setupNavigationBarView()
        
        // TabBar
        setupTabBarStyle()
        
        // TableView
        setupPasswordTableView()
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: true,
                               backButtonImage: nil,
                               backButtonTitle: translate(.Password),
                               displayMode: .password)
    }
    
    private func setupPasswordTableView() {
        passwordTableView.delegate = self
        passwordTableView.dataSource = self
        passwordTableView.register(PasswordMainTableViewCell.loadFromNib(),
                                   forCellReuseIdentifier: PasswordMainTableViewCell.identifier)
    }
    
    // MARK: - Function
    
    /// 設定 NotificationCenter 監聽
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showInvaildQRCodeFormatAlert),
                                               name: .showInvaildQRCodeFormatAlert,
                                               object: nil)
    }
    
    @objc func showInvaildQRCodeFormatAlert() {
        Alert.showAlertWith(title: translate(.Error),
                            message: translate(.The_QR_Code_format_is_wrong_it_can_only_be_used_to_scan_the_QR_Code_generated_by_the_Cmore_browser_extension),
                            vc: self,
                            confirmTitle: translate(.Confirm),
                            confirm: nil)
    }
    
    // MARK: - Fetch Data From Database
    
    func fetchDataFromDatabase() {
        passwordModel = LocalDatabase.shared.fetch(table: .password)
        SingletonPatternOfPasswordAndNotes.shared.passwordArray = passwordModel
        
        DispatchQueue.main.async { [self] in
            passwordTableView.reloadData()
            
            // 若資料庫資料筆數小於 2 筆，搜尋的按鈕就不能使用
            if passwordModel.count > 1 {
                vNavigationBar.btnRight1.isEnabled = true
                vNavigationBar.btnRight1.tintColor = UIColor.white.withAlphaComponent(1)
            } else {
                vNavigationBar.btnRight1.isEnabled = false
                vNavigationBar.btnRight1.tintColor = UIColor.white.withAlphaComponent(0.5)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PasswordMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PasswordMainTableViewCell.identifier,
                                                       for: indexPath) as? PasswordMainTableViewCell else {
            fatalError("PasswordMainTableViewCell 載入失敗")
        }
        cell.setupUI(title: passwordModel[indexPath.row].title,
                     account: passwordModel[indexPath.row].account,
                     buttonShowMenu: true,
                     index: indexPath.row,
                     delegate: self)
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        SingletonPatternOfPasswordAndNotes.shared.id = passwordModel[indexPath.row].id
        SingletonPatternOfPasswordAndNotes.shared.title = passwordModel[indexPath.row].title
        SingletonPatternOfPasswordAndNotes.shared.account = passwordModel[indexPath.row].account
        SingletonPatternOfPasswordAndNotes.shared.password = passwordModel[indexPath.row].password
        SingletonPatternOfPasswordAndNotes.shared.url = passwordModel[indexPath.row].url
        SingletonPatternOfPasswordAndNotes.shared.note = passwordModel[indexPath.row].note
        
        let nextVC = EditPasswordViewController()
        DispatchQueue.main.async {
            self.pushViewController(nextVC: nextVC)
        }
    }
    
    /// 通過長按方式觸發 Context Menu
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let detailsAction = UIAction(title: translate(.Details),
                                     image: UIImage(icon: .edit)) { [unowned self] action in
            SingletonPatternOfPasswordAndNotes.shared.id = passwordModel[indexPath.row].id
            SingletonPatternOfPasswordAndNotes.shared.title = passwordModel[indexPath.row].title
            SingletonPatternOfPasswordAndNotes.shared.account = passwordModel[indexPath.row].account
            SingletonPatternOfPasswordAndNotes.shared.password = passwordModel[indexPath.row].password
            SingletonPatternOfPasswordAndNotes.shared.url = passwordModel[indexPath.row].url
            SingletonPatternOfPasswordAndNotes.shared.note = passwordModel[indexPath.row].note
            
            let nextVC = EditPasswordViewController()
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        }
        
        let deleteAction = UIAction(title: translate(.Delete),
                                    image: UIImage(icon: .trash),
                                    attributes: .destructive) { [unowned self] action in
            LocalDatabase.shared.delete(id: passwordModel[indexPath.row].id, table: .password)
            fetchDataFromDatabase()
        }
        
        // 返回 UIContextMenuConfiguration
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [detailsAction, deleteAction])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - NavigationBarViewDelegate

extension PasswordMainViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        //
    }
    
    func btnRightClicked(index: Int) {
        switch index {
        case 0:
            // 搜尋密碼／記事
            print("尋找密碼")
            let nextVC = SearchViewController()
            nextVC.root = .password
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        case 1:
            // 新增密碼／記事
            print("新增密碼")
            let nextVC = AddPasswordViewController()
            nextVC.showFirstAddAlertDelegate = self
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        default:
            break
        }
    }
}

// MARK: - PasswordMainTableViewCellDelegate

extension PasswordMainViewController: PasswordMainTableViewCellDelegate {
    
    func btnClicked(buttonType: AppDefine.MainMoreButtonMenu, index: Int) {
        switch buttonType {
        case .detail:
            print(passwordModel[index].id)
            
            SingletonPatternOfPasswordAndNotes.shared.id = passwordModel[index].id
            SingletonPatternOfPasswordAndNotes.shared.title = passwordModel[index].title
            SingletonPatternOfPasswordAndNotes.shared.account = passwordModel[index].account
            SingletonPatternOfPasswordAndNotes.shared.password = passwordModel[index].password
            SingletonPatternOfPasswordAndNotes.shared.url = passwordModel[index].url
            SingletonPatternOfPasswordAndNotes.shared.note = passwordModel[index].note

            let nextVC = EditPasswordViewController()
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        case .delete:
            Alert.showAlertWith(title: translate(.Warnings),
                                message: translate(.The_selected_data_will_be_deleted_soon_and_cannot_be_recovered_after_deletion_Please_confirm_whether_to_continue),
                                vc: self,
                                confirmTitle: translate(.Delete),
                                cancelTitle: translate(.Cancel)) { [unowned self] in
                LocalDatabase.shared.delete(id: passwordModel[index].id, table: .password)
                fetchDataFromDatabase()
            } cancel: {
                //
            }
        }
    }
}

// MARK: - ShowFirstAddAlertDelegate

extension PasswordMainViewController: ShowFirstAddAlertDelegate {
    
    func showAlert() {
        Alert.showAlertWith(title: "",
                            message: translate(.This_is_the_first_time_to_add_to_avoid_data_loss_please_remember_to_go_to_Settings_Backup_Restore_to_make_a_backup),
                            vc: self,
                            confirmTitle: translate(.Go_to_Settings),
                            cancelTitle: translate(.Close),
                            confirm: {
            let nextVC = CKBackupRestoreViewController()
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        }, cancel: nil)
        UserPreferences.shared.isFirstAddPasswordOrNotes = true
    }
}
