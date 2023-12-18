//
//  RegisterViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/12/16.
//

import UIKit
import FMDB

class RegisterViewController: BaseViewController {
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: - Variables
    
    var database: FMDatabase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        // NavigationBar
        setupNavigationBarView()
        
        // TabBar
        setupTabBarStyle()
        
        // TextField
        setupTextFields()
        
        // Button
        registerButton.setTitle(translate(.Register), for: .normal)
        registerButton.tintColor = .white
        registerButton.layer.cornerRadius = registerButton.bounds.height/6
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
    
    func isEmailRegistered(email: String) -> Bool{
        var isEmailRegistered = false
        if connectDB() {
            let query = "SELECT phone FROM USER WHERE email = ?"
            do {
                let results: FMResultSet = try database.executeQuery(query, values: [email])
                while results.next() {
                    isEmailRegistered = true
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return isEmailRegistered
    }
    
    func isPhoneRegistered(phone: String) -> Bool{
        var isPhoneRegistered = false
        if connectDB() {
            let query = "SELECT phone FROM USER WHERE phone = ?"
            do {
                let results: FMResultSet = try database.executeQuery(query, values: [phone])
                while results.next() {
                    isPhoneRegistered = true
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return isPhoneRegistered
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Register),
                               displayMode: .noRightButtons)
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        // 信箱
        emailTextField.placeholder = translate(.Email)
        
        // 手機
        phoneTextField.placeholder = translate(.Phone)
        
        // 密碼
        passwordTextField.placeholder = translate(.Password)
        
        // 確認密碼
        confirmPasswordTextField.placeholder = translate(.Confirm_password)
        
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^09[0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    @IBAction func registerAccount(_ sender: Any) {
        if (emailTextField.text == "" || phoneTextField.text == "" || passwordTextField.text == "" || confirmPasswordTextField.text == "") {
            Alert.showToastWith(message: "必填欄位不得為空！",
                                vc: self,
                                during: .short)
        }
        else{
            if (isValidEmail(email: emailTextField.text!) == false || (isValidPhoneNumber(phoneNumber: phoneTextField.text!) == false)) {
                Alert.showToastWith(message: "請確認是否輸入有效的信箱、電話！",
                                    vc: self,
                                    during: .short)
            }
            else if (passwordTextField.text != confirmPasswordTextField.text) {
                Alert.showToastWith(message: "密碼不一致！",
                                    vc: self,
                                    during: .short)
            }
            else{
                if (isEmailRegistered(email: emailTextField.text!) == true) {
                    Alert.showToastWith(message: "此信箱已被註冊", vc: self, during: .short)
                }
                else if (isPhoneRegistered(phone: phoneTextField.text!) == true) {
                    Alert.showToastWith(message: "此電話已被註冊", vc: self, during: .short)
                }
                else {
                    LocalDatabase.shared.register(id: UUID().uuidString, email: emailTextField.text!, phone: phoneTextField.text!, password: passwordTextField.text!, table: .user)
                    Alert.showToastWith(message: "註冊成功！",
                                        vc: self,
                                        during: .short, dismiss: {
                        self.popToRootViewController()
                    })
                }
            }
        }
    }
    @objc func backButtonAction(){
        if (emailTextField.text == "" &&
            phoneTextField.text == "" &&
            passwordTextField.text == "" &&
            confirmPasswordTextField.text == "") {
            print("輸入框為空值")
            popToRootViewController()
        }
        else {
            print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_register),
                                message: translate(.The_currently_entered_data_has_not_been_saved_Do_you_want_to_leave_this_screen),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                cancelTitle: translate(.Cancel)) {
                print("pop to top vc")
                self.popViewController()
            } cancel: {
                print("will edit")
            }
        }
    }
}
// MARK: - NavigationBarViewDelegate

extension RegisterViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        //
    }
}

