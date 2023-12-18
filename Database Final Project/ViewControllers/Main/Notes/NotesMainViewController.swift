//
//  NotesMainViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/1.
//

import UIKit

class NotesMainViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var notesTableView: UITableView!
    
    // MARK: - Variables
    
    var notesModel: [NotesModel] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        setupNotesTableView()
    }
    
    private func setupNotesTableView() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.register(NotesMainTableViewCell.loadFromNib(),
                                forCellReuseIdentifier: NotesMainTableViewCell.identifier)
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: true,
                               backButtonImage: nil,
                               backButtonTitle: translate(.Notes),
                               displayMode: .notes)
    }
    
    // MARK: - Fetch Data From Database
    
    func fetchDataFromDatabase() {
        notesModel = LocalDatabase.shared.fetch(table: .note)
        SingletonPatternOfPasswordAndNotes.shared.noteArray = notesModel
        
        DispatchQueue.main.async { [self] in
            notesTableView.reloadData()
            
            // 若資料庫資料筆數小於 2 筆，搜尋的按鈕就不能使用
            if notesModel.count > 1 {
                vNavigationBar.btnRight1.isEnabled = true
                vNavigationBar.btnRight1.tintColor = UIColor.white.withAlphaComponent(1)
            } else {
                vNavigationBar.btnRight1.isEnabled = false
                vNavigationBar.btnRight1.tintColor = UIColor.white.withAlphaComponent(0.5)
            }
        }
    }
}

// MARK: - UITableViewDelegate、UITableViewDataSource

extension NotesMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotesMainTableViewCell.identifier,
                                                       for: indexPath) as? NotesMainTableViewCell else {
            fatalError("NotesMainTableViewCell 載入失敗")
        }
        
        cell.setupUI(title: notesModel[indexPath.row].title,
                     buttonShowMenu: true,
                     index: indexPath.row,
                     delegate: self)
        return cell
    }
    
    // UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        SingletonPatternOfPasswordAndNotes.shared.id = notesModel[indexPath.row].id
        SingletonPatternOfPasswordAndNotes.shared.title = notesModel[indexPath.row].title
        SingletonPatternOfPasswordAndNotes.shared.note = notesModel[indexPath.row].note
        
        let nextVC = EditNotesViewController()
        DispatchQueue.main.async {
            self.pushViewController(nextVC: nextVC)
        }
    }
    
    /// 通過長按方式觸發 Context Menus
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let detailsAction = UIAction(title: translate(.Details),
                                     image: UIImage(icon: .edit)) { [unowned self] action in
            SingletonPatternOfPasswordAndNotes.shared.id = notesModel[indexPath.row].id
            SingletonPatternOfPasswordAndNotes.shared.title = notesModel[indexPath.row].title
            SingletonPatternOfPasswordAndNotes.shared.note = notesModel[indexPath.row].note
            
            let nextVC = EditNotesViewController()
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        }
        
        let deleteAction = UIAction(title: translate(.Delete),
                                    image: UIImage(icon: .trash),
                                    attributes: .destructive) { [unowned self] action in
            LocalDatabase.shared.delete(id: notesModel[indexPath.row].id, table: .note)
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

extension NotesMainViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        //
    }
    
    func btnRightClicked(index: Int) {
        switch index {
        case 0:
            print("尋找記事")
            let nextVC = SearchViewController()
            nextVC.root = .notes
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        case 1:
            print("新增記事")
            let nextVC = AddNotesViewController()
            nextVC.showFirstAddAlertDelegate = self
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        default:
            break
        }
    }
}

// MARK: - NotesMainTableViewCellDelegate

extension NotesMainViewController: NotesMainTableViewCellDelegate {
    
    func btnClicked(buttonType: AppDefine.MainMoreButtonMenu, index: Int) {
        switch buttonType {
        case .detail:
            SingletonPatternOfPasswordAndNotes.shared.id = notesModel[index].id
            SingletonPatternOfPasswordAndNotes.shared.title = notesModel[index].title
            SingletonPatternOfPasswordAndNotes.shared.note = notesModel[index].note
            print(SingletonPatternOfPasswordAndNotes.shared.note)
            let nextVC = EditNotesViewController()
            DispatchQueue.main.async {
                self.pushViewController(nextVC: nextVC)
            }
        case .delete:
            Alert.showAlertWith(title: translate(.Warnings),
                                message: translate(.The_selected_data_will_be_deleted_soon_and_cannot_be_recovered_after_deletion_Please_confirm_whether_to_continue),
                                vc: self,
                                confirmTitle: translate(.Delete),
                                cancelTitle: translate(.Cancel)) { [unowned self] in
                LocalDatabase.shared.delete(id: notesModel[index].id, table: .note)
                fetchDataFromDatabase()
            } cancel: {
                //
            }
        }
    }
}

// MARK: - ShowFirstAddAlertDelegate

extension NotesMainViewController: ShowFirstAddAlertDelegate {
    
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
