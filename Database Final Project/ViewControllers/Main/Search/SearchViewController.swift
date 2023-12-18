//
//  SearchViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/30.
//

import UIKit

class SearchViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var searchTableView: UITableView!
    
    // MARK: - Variables
    
    var root: Root = .password
    var searchPasswordModel: [PasswordModel] = []
    var searchNotesModel: [NotesModel] = []
    
    enum Root {
        
        /// 從密碼頁面進來
        case password
        
        /// 從記事頁面進來
        case notes
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        fetchDataFromDatabase()
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupNavigationBarView()
        setupSearchTableView()
        addSearchBar()
    }
    
    private func setupSearchTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(SearchTableViewCell.loadFromNib(),
                                 forCellReuseIdentifier: SearchTableViewCell.identifier)
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Search),
                               displayMode: .noRightButtons)
    }
    
    private func addSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        searchBar.barStyle = .default
        searchBar.isTranslucent = true
        searchBar.placeholder = translate(.Search)
        searchBar.delegate = self
        searchTableView.tableHeaderView = searchBar
    }
    
    func search(_ searchTerm: String) {
        switch root {
        case .password:
            if searchTerm.isEmpty == false {
                searchPasswordModel = LocalDatabase.shared.fetch(table: .password).filter {
                    $0.title.localizedCaseInsensitiveContains(searchTerm) // 搜尋時不區分英文大小寫
                }
                #if DEBUG
                print(searchPasswordModel)
                #endif
            }
        case .notes:
            if searchTerm.isEmpty == false {
                searchNotesModel = LocalDatabase.shared.fetch(table: .note).filter {
                    $0.title.localizedCaseInsensitiveContains(searchTerm) // 搜尋時不區分英文大小寫
                }
                #if DEBUG
                print(searchNotesModel)
                #endif
            }
        }
        searchTableView.reloadData()
    }
    
    // MARK: - Fetch Data From Database
    
    func fetchDataFromDatabase() {
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension SearchViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        popViewController()
    }
    
    func btnRightClicked(index: Int) {
        //
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch root {
        case .password:
            return searchPasswordModel.count
        case .notes:
            return searchNotesModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier,
                                                       for: indexPath) as? SearchTableViewCell else {
            fatalError("PasswordMainTableViewCell 載入失敗")
        }
        switch root {
        case .password:
            cell.setInit(root: .password,
                         title: searchPasswordModel[indexPath.row].title,
                         account: searchPasswordModel[indexPath.row].account,
                         index: indexPath.row)
        case .notes:
            cell.setInit(root: .notes,
                         title: searchNotesModel[indexPath.row].title,
                         account: searchNotesModel[indexPath.row].note,
                         index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch root {
        case .password:
            SingletonPatternOfPasswordAndNotes.shared.id = self.searchPasswordModel[indexPath.row].id
            SingletonPatternOfPasswordAndNotes.shared.title = self.searchPasswordModel[indexPath.row].title
            SingletonPatternOfPasswordAndNotes.shared.account = self.searchPasswordModel[indexPath.row].account
            SingletonPatternOfPasswordAndNotes.shared.password = self.searchPasswordModel[indexPath.row].password
            SingletonPatternOfPasswordAndNotes.shared.url = self.searchPasswordModel[indexPath.row].url
            SingletonPatternOfPasswordAndNotes.shared.note = self.searchPasswordModel[indexPath.row].note
            
            let nextVC = EditPasswordViewController()
            self.pushViewController(nextVC, animated: false) {
            }
        case .notes:
            SingletonPatternOfPasswordAndNotes.shared.id = self.searchNotesModel[indexPath.row].id
            SingletonPatternOfPasswordAndNotes.shared.title = self.searchNotesModel[indexPath.row].title
            SingletonPatternOfPasswordAndNotes.shared.note = self.searchNotesModel[indexPath.row].note
            
            let nextVC = EditNotesViewController()
            self.pushViewController(nextVC, animated: false) {
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
        if searchText == "" {
            searchPasswordModel = []
            searchNotesModel = []
            searchTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchTableView.reloadData()
    }
}
