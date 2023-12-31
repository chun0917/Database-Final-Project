//
//  MainViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/6/20.
//

import UIKit
import FMDB

class LoginViewController: BaseViewController {
    
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
        print("isSignIn:",UserPreferences.shared.isSignIn)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    // 判斷是否成功連線至資料庫
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
    
    // Email 正則
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // 成功登入時，獲取用戶註冊的手機
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
    
    // 成功登入時，獲取用戶的userID
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
        emailTextField.text = ""
        
        // 密碼
        passwordTextField.placeholder = translate(.Password)
        passwordTextField.text = ""
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
                Alert.showToastWith(message: translate(.Email_and_password_cannot_be_empty),
                                    vc: self,
                                    during: .short)
            }
            else if (isValidEmail(email: emailTextField.text!) == false) {
                Alert.showToastWith(message: translate(.Please_input_valid_email),
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
                            Alert.showToastWith(message: translate(.Login_success),
                                                vc: self,
                                                during: .short
                                                , dismiss:  {
                                UserPreferences.shared.isSignIn = true
                                let passwordVC = PasswordMainViewController()
                                let notesVC = NotesMainViewController()
                                let settingsVC = SettingsViewController()
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
                            Alert.showToastWith(message: translate(.Email_is_not_exist_or_incorrect_password),
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
        let alertController = UIAlertController(title: translate(.Get_verify_code), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = translate(.Input_phone_number)
        }
        // 添加一個確認按鈕
        let confirmAction = UIAlertAction(title: translate(.Confirm), style: .default) { [unowned self] _ in
            // 獲取使用者輸入的文字
            if let phoneNumber = alertController.textFields?.first?.text {
                print("Entered phoneNumber: \(phoneNumber)")
                if self.connectDB() {
                    let query = "SELECT * FROM USER WHERE phone = ?"
                    do{
                        let results: FMResultSet = try database.executeQuery(query, values: [phoneNumber])
                        if (results.next()) {
                            let verifyCode = Int.random(in: 100000 ..< 1000000)
                            UserNotifications.shared.add(identifier: .icloud, subTitle: translate(.Verify_code), body: translate(.Verify_code) + ":\(verifyCode)")
                            let alertControllers = UIAlertController(title: translate(.Input_verify_code), message: nil, preferredStyle: .alert)
                            alertControllers.addTextField { textField in
                                textField.placeholder = translate(.Verify_code)
                            }
                            // 添加一個確認按鈕
                            let confirmActions = UIAlertAction(title: translate(.Confirm), style: .default){ [self] _ in
                                if let inputVerifyCode = alertControllers.textFields?.first?.text {
                                    if (inputVerifyCode == "\(verifyCode)") {
                                        let resetQuery = "UPDATE USER SET password = ? WHERE phone = ?"
                                        do {
                                            try database.executeUpdate(resetQuery, values: ["000000",phoneNumber])
                                            Alert.showToastWith(message: translate(.Reset_your_password_to_000000), vc: self, during: .short)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    else {
                                        Alert.showToastWith(message: translate(.Verify_code_is_incorrect_please_try_again), vc: self, during: .short)
                                    }
                                }
                            }
                            alertControllers.addAction(confirmActions)
                            // 顯示 UIAlertController
                            present(alertControllers, animated: true, completion: nil)
                        }
                        else {
                            Alert.showToastWith(message: translate(.Phone_number_isnot_exist),
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
        let cancelAction = UIAlertAction(title: translate(.Cancel), style: .cancel, handler: nil)
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
