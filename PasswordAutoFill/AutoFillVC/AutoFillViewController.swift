//
//  AutoFillViewController.swift
//  PasswordAutoFill
//
//  Created by 呂淳昇 on 2022/7/6.
//

import UIKit
import AuthenticationServices

/*
 import AuthenticationServices 才能呼叫
 ASCredentialProviderViewController、
 ASExtensionErrorDomain、
 ASExtensionError.userCanceled.rawValue
 */

// class 的類型一定要是 ASCredentialProviderViewController 才能 cancelRequest、completeRequest
class AutoFillViewController: ASCredentialProviderViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var addAccountLabel: UILabel!
    @IBOutlet weak var btnAddAccount: UIButton!
    @IBOutlet weak var tvAccountItem: UITableView!
    
    // MARK: - Variables
    
    var passwordListModel: [PasswordModel] = []
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        LocalDatabase.shared.filePath = UserPreferences.shared.databasePath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.global().async {
            self.fetchFromDatabase()
        }
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        addAccountLabel.text = translate(.Extension_Add_Account)
        
        btnAddAccount.setTitle("", for: .normal)
        
        setupTableView()
        
        checkIsSignIn()
    }
    
    func addBackgroundView() {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: btnCancel.accessibilityFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        imageView.backgroundColor = .white
        
        self.view.addSubview(imageView)
    }
    
    
    func checkIsSignIn(){
        if (UserPreferences.shared.isSignIn == false) {
            addBackgroundView()
            Alert.showAlertWithError(message: translate(.Please_login_first), vc: self, confirmTitle: translate(.Confirm)) {
                self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                                       code: ASExtensionError.userCanceled.rawValue))
            }
        }
    }
    
    private func setupTableView() {
        tvAccountItem.delegate = self
        tvAccountItem.dataSource = self
        tvAccountItem.register(AutoFillTVC.loadFromNib(),
                               forCellReuseIdentifier: AutoFillTVC.identifier)
    }
    
    // MARK: - Fetch Data From Database
    
    func fetchFromDatabase() {
        passwordListModel = LocalDatabase.shared.fetch(table: .password)
        
        DispatchQueue.main.async {
            self.tvAccountItem.reloadData()
        }
    }

    // MARK: - IBAction
    
    @IBAction func touchBtnCancel(_ sender: UIBarButtonItem) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain,
                                                               code: ASExtensionError.userCanceled.rawValue))
    }
    
    @IBAction func touchBtnAddAccount(_ sender: UIButton) {
        let nextVC = NewAddViewController()
        nextVC.isModalInPresentation = true // 取消拖曳返回之前頁面
        nextVC.delegate = self
        self.present(nextVC, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AutoFillViewController: UITableViewDelegate, UITableViewDataSource {
    
    // UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordListModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutoFillTVC.identifier,
                                                       for: indexPath) as? AutoFillTVC else {
            fatalError("AutoFillTableViewCell 載入失敗")
        }
        
        cell.setInit(title: passwordListModel[indexPath.row].title,
                     detail: passwordListModel[indexPath.row].account,
                     iconName: .key)
        
        return cell
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let passwordCredential = ASPasswordCredential(user: passwordListModel[indexPath.row].account,
                                                      password: passwordListModel[indexPath.row].password)
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential,
                                              completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - NewAddAccountVCCellItemProtocol

extension AutoFillViewController: NewAddAccountVCCellItemProtocol {
    
    func reloadData() {
        passwordListModel = LocalDatabase.shared.fetch(table: .password)
        DispatchQueue.main.async {
            self.tvAccountItem.reloadData()
        }
    }
}

/*
 
 https://www.csdn.net/tags/MtjaEgwsODI2OC1ibG9n.html
 
 介紹 autofill 如何建檔
 https://juejin.cn/post/6885176823714414605
 
 實施自動填充憑據提供程序擴展
 https://nilotic.github.io/2018/09/07/Implementing-AutoFill-Credential-Provider-Extensions.html
 
 在 iOS 應用程序和擴展程序之間共享信息
 https://rderik.com/blog/sharing-information-between-ios-app-and-an-extension/

 1. 如何在iOS8上以無 Storyboard的方式以程式設計方式建立Today小部件？
 https://www.796t.com/post/MW95NDI=.html
 
 2. iOS Today App Extension 制作
 https://www.jianshu.com/p/65cc7098371f
 
 */
