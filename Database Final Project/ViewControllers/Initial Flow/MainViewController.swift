//
//  MainViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/20.
//

import UIKit
import FMDB

class MainViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomPasswordLockTextField!
    
    // MARK: - Variables
    
    var database: FMDatabase!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserPreferences.shared.isSignIn = false
        print(UserPreferences.shared.isSignIn)
        setupUI()
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        // NavigationBar
        setupNavigationBarView()
        
        // Button
        setupButtons()
        
        // TextField
        setupTextFields()
        
        // Label
        setupLabels()
    }
    
    /// 判斷是否成功連線至資料庫
    func connectDB() -> Bool {
        var isOpen: Bool = false
        self.database = FMDatabase(path: UserPreferences.shared.databasePath)
        if self.database != nil {
            if self.database.open() {
                isOpen = true
            } else {
                print("未連線至資料庫")
            }
        }
        return isOpen
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func fetchPhone(email: String){
        let query = "SELECT phone FROM USER WHERE email = ?"
        do {
            let results: FMResultSet = try database.executeQuery(query, values: [email])
            while results.next() {
                UserPreferences.shared.phone = (results.string(forColumn: "phone")!.data(using: .utf8)!)
                if (UserPreferences.shared.phone.count < 32) {
                    for _ in UserPreferences.shared.phone.count ..< 32 {
                        UserPreferences.shared.phone.append(contentsOf: [0])
                    }
                }
                print("phone:",UserPreferences.shared.phone.bytes)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUserID(email: String){
        let query = "SELECT userID FROM USER WHERE email = ?"
        do {
            let results: FMResultSet = try database.executeQuery(query, values: [email])
            while results.next() {
                UserPreferences.shared.userID = results.string(forColumn: "userID")!
                print("userID:",UserPreferences.shared.userID)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.setInit(backButtonIsHidden: true,
                               backButtonImage: nil,
                               backButtonTitle: translate(.Login),
                               displayMode: .noRightButtons)
    }
    
    /// 設定 Button 樣式
    private func setupButtons() {
        loginButton.setTitle(translate(.Login), for: .normal)
        loginButton.tintColor = .white
        loginButton.layer.cornerRadius = loginButton.bounds.height/6
        registerButton.setTitle(translate(.Register), for: .normal)
        registerButton.tintColor = .white
        registerButton.layer.cornerRadius = loginButton.bounds.height/6
        forgetPasswordButton.setTitle(translate(.Forget_password), for: .normal)
        forgetPasswordButton.tintColor = .blue
        forgetPasswordButton.layer.cornerRadius = loginButton.bounds.height/6
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        // 信箱
        emailTextField.placeholder = translate(.Email)
        
        // 密碼
        passwordTextField.placeholder = translate(.Password)
    }
    
    /// 設定 Label 樣式
    private func setupLabels(){
        welcomeLabel.text = translate(.Welcome)
        welcomeLabel.textColor = .blue
        welcomeLabel.font = UIFont.systemFont(ofSize: 30.0)
    }
    
    // MARK: - IBAction
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        if (UserPreferences.shared.isSignIn == false) {
            if (emailTextField.text == "" || emailTextField.text == "") {
                Alert.showToastWith(message: "信箱密碼不得為空！",
                                    vc: self,
                                    during: .short)
            }
            else if (isValidEmail(email: emailTextField.text!) == false) {
                Alert.showToastWith(message: "請輸入有效的信箱！",
                                    vc: self,
                                    during: .short)
            }
            else {
                if connectDB() {
                    let query = LocalDatabase.SQLCommands.user.fetch
                    do{
                        let results: FMResultSet = try database.executeQuery(query, values: [emailTextField.text!, passwordTextField.text!])
                        if (results.next()) {
                            fetchPhone(email: emailTextField.text!)
                            fetchUserID(email: emailTextField.text!)
                            Alert.showToastWith(message: "登入成功",
                                                vc: self,
                                                during: .short
                                                , dismiss:  {
                                UserPreferences.shared.isSignIn = true
                                let passwordVC = PasswordMainViewController()
                                let notesVC = NotesMainViewController()
                                let settingsVC = SettingsMainViewController()
                                let vcsArray = [passwordVC, notesVC, settingsVC]
                                let vcTitleArray = [translate(.Password), translate(.Notes), translate(.Settings)]
                                let imageNameArray: [SFSymbols] = [.key, .notes, .settings]
                                let nextVC = self.createTabBarController(vcs: vcsArray,
                                                                         vcTitleArray: vcTitleArray,
                                                                         imageNameArray: imageNameArray,
                                                                         modelPresentationStyle: .fullScreen)
                                self.pushViewController(nextVC, animated: true)
                            })
                        }
                        else {
                            Alert.showToastWith(message: "未存在此信箱或密碼錯誤！",
                                                vc: self,
                                                during: .long)
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    @IBAction func forgetPasswordBtnClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter Text", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Type something..."
        }
        // 添加一個確認按鈕
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            // 獲取使用者輸入的文字
            if let text = alertController.textFields?.first?.text {
                print("Entered text: \(text)")
                if self.connectDB() {
                    let query = "SELECT * FROM USER WHERE phone = ?"
                    do{
                        let results: FMResultSet = try database.executeQuery(query, values: [text])
                        if (results.next()) {
                            let verifyCode = Int.random(in: 100000 ..< 1000000)
                            UserNotifications.shared.add(identifier: .icloud, subTitle: "test", body: "驗證碼是\(verifyCode)")
                            let alertControllers = UIAlertController(title: "Enter Text", message: nil, preferredStyle: .alert)
                            alertControllers.addTextField { textField in
                                textField.placeholder = "Type something..."
                            }
                            // 添加一個確認按鈕
                            let confirmActions = UIAlertAction(title: "OK", style: .default){ _ in
                                if let texts = alertControllers.textFields?.first?.text {
                                    if (texts == "\(verifyCode)") {
                                        let querys = "UPDATE USER SET password = ? WHERE phone = ?"
                                        do {
                                            try database.executeUpdate(querys, values: ["000000",text])
                                            Alert.showToastWith(message: "已重設密碼為000000", vc: self, during: .short)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                            alertControllers.addAction(confirmActions)
                            // 顯示 UIAlertController
                            present(alertControllers, animated: true, completion: nil)
                        }
                        else {
                            Alert.showToastWith(message: "未存在此電話！",
                                                vc: self,
                                                during: .long)
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        alertController.addAction(confirmAction)
        
        // 添加一個取消按鈕
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 顯示 UIAlertController
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func registerBtnClicked(_ sender: Any) {
        print("跳註冊畫面")
        let nextVC = RegisterViewController()
        self.pushViewController(nextVC, animated: true)
    }
}
