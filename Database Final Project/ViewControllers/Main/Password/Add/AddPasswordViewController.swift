//
//  AddPasswordViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/15.
//

import UIKit
import IQKeyboardManagerSwift

class AddPasswordViewController: BaseViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var vStatusBar: StatusBarView!
    @IBOutlet weak var vNavigationBar: NavigationBarView!
    @IBOutlet var requiredLabels: [UILabel]!
    @IBOutlet weak var titleTextField: CustomTextField!
    @IBOutlet weak var accountTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomPasswordLockTextField!
    @IBOutlet weak var getNewPasswordButton: UIButton!
    @IBOutlet weak var urlTextField: CustomTextField!
    @IBOutlet weak var noteTextView: IQTextView!
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet weak var showAdvancedSettingsButton: UIButton!
    @IBOutlet weak var hideAdvancedSettingsButton: UIButton!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var accountCountLabel: UILabel!
    @IBOutlet weak var passwordCountLabel: UILabel!
    @IBOutlet weak var urlCountLabel: UILabel!
    @IBOutlet weak var notesCountLabel: UILabel!
    
    // MARK: - Variables
    
    var receivePassword: String = "" // 從安全密碼產生器傳過來的密碼
    
    weak var delegate: AddPasswordViewControllerDelegate?
    weak var showFirstAddAlertDelegate: ShowFirstAddAlertDelegate?
    
    var root: Root = .password
    
    enum Root {
        case password // 走一般流程呼叫的
        case chromeExtension // 走 Chrome Extension 流程呼叫的
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        
        // 設定 NavigationBar 樣式
        setupNavigationBarView()
        
        if root == .chromeExtension {
            self.navigationController?.presentationController?.delegate = self
        }
        
        // 設定 TextField 樣式
        setupTextFields()
        
        // 設定 noteTextView 樣式
        setupNotesTextView()
        
        setupCountLabel()
        
        // 設定 `顯示進階設定` 跟 `隱藏進階設定` 的按鈕樣式
        showAdvancedSettingsButton.setTitle(translate(.Show_Advanced_Settings), for: .normal)
        hideAdvancedSettingsButton.setTitle(translate(.Hide_Advanced_Settings), for: .normal)
        
        // 設定`產生新密碼` 底線樣式
        let textAttributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: 20),             // 文字大小、字體樣式
            .foregroundColor : #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) ,                            // 文字顏色
            .underlineStyle : NSUnderlineStyle.single.rawValue // .single 單條底線 .double .thick 單條粗底線
        ]
        let getNewPasswordAttribute = NSMutableAttributedString(
            string: translate(.Get_New_Password),
            attributes: textAttributes
        )
        getNewPasswordButton.setAttributedTitle(getNewPasswordAttribute, for: .normal)
        
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
        requiredLabels[2].text = translate(.Required)
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: (root == .chromeExtension) ? true : false,
                               backButtonImage: (root == .chromeExtension) ? nil : UIImage(icon: .back),
                               backButtonTitle: (root == .chromeExtension) ? translate(.Cancel) : translate(.Add),
                               displayMode: .leftRight,
                               btnIcon2: .save)
    }
    
    /// 設定字數統計 Label 樣式
    private func setupCountLabel() {
        titleCountLabel.text = "\(0)/35"
        accountCountLabel.text = "\(0)/100"
        passwordCountLabel.text = "\(0)/50"
        urlCountLabel.text = "\(0)/100"
        notesCountLabel.text = "\(0)/100"
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        // 標題
        titleTextField.text = SingletonPatternOfPasswordAndNotes.shared.title
        titleTextField.placeholder = translate(.Title)
        titleTextField.delegate = self
        
        // 帳號
        accountTextField.text = SingletonPatternOfPasswordAndNotes.shared.account
        accountTextField.placeholder = translate(.Account)
        accountTextField.delegate = self
        
        // 密碼
        passwordTextField.text = SingletonPatternOfPasswordAndNotes.shared.password
        passwordTextField.placeholder = translate(.Password)
        passwordTextField.delegate = self
        
        // 網址
        urlTextField.text = SingletonPatternOfPasswordAndNotes.shared.url
        urlTextField.placeholder = translate(.URL)
        urlTextField.delegate = self
    }
    
    /// 設定 notesTextView 樣式
    private func setupNotesTextView() {
        noteTextView.layer.borderColor = UIColor.gray.cgColor
        noteTextView.layer.borderWidth = 2
        noteTextView.layer.cornerRadius = noteTextView.bounds.height/10
        noteTextView.showsVerticalScrollIndicator = true // 垂直滾動指示器
        noteTextView.showsHorizontalScrollIndicator = false // 水平滾動指示器
        noteTextView.text = SingletonPatternOfPasswordAndNotes.shared.note
        noteTextView.placeholder = translate(.Note)
        noteTextView.delegate = self
    }
        
    // MARK: - NavigationBarButtonItems Actions
    
    @objc func backButtonAction() {
        if (titleTextField.text == "" &&
            accountTextField.text == "" &&
            passwordTextField.text == "" &&
            urlTextField.text == "" &&
            noteTextView.text == "") {
            print("輸入框為空值")
            if root == .chromeExtension {
                self.dismiss(animated: true)
            } else {
                popToRootViewController()
            }
        } else {
            print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_Add),
                                message: translate(.The_currently_entered_data_has_not_been_saved_Do_you_want_to_leave_this_screen),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                cancelTitle: translate(.Cancel)) {
                print("pop to top vc")
                if self.root == .chromeExtension {
                    self.dismiss(animated: true)
                } else {
                    self.popViewController()
                }
            } cancel: {
                print("will edit")
            }
        }
    }
    
    @objc func saveButtonAction() {
        if (titleTextField.text == "" ||
            accountTextField.text == "" ||
            passwordTextField.text == "") {
            print("請確認必填欄位皆已輸入")
            Alert.showAlertWith(title: "",
                                message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                confirmTitle: translate(.Confirm))
        } else {
            print("必填欄位皆已填寫，但網址、備註可為空值")
            // 按下儲存按鈕後要做的事 ...
            Alert.showToastWith(message: translate(.Save_Password_Succeed),
                                vc: self,
                                during: .long) { [unowned self] in
                // 新增密碼
                let pm = PasswordModel(id: UUID().uuidString,
                                       title: titleTextField.text!,
                                       account: accountTextField.text!,
                                       password: passwordTextField.text!,
                                       url: urlTextField.text!,
                                       note: noteTextView.text!)
                let cryptoManager = CryptoManager()
                
                /// Step0：原始資料
                guard let pmData = cryptoManager.classToJsonData(input: pm) else { return }
                print(String(data: pmData, encoding: .utf8)!)
                
                /// Step1：privateKey
                let privateKey = UserPreferences.shared.privateKeyForDatabase
                /// Step2：privateKey 經過 SHA256 Hash 得出 preIV
                let preIV = cryptoManager.generatePreIV(privateKey: privateKey)
                /// Step3：preIV 取前 16Bytes 得出 IV
                let iv = cryptoManager.generateIV(preIV: preIV)
                let ivToString = iv.toHexString()
                /// Step4：IV + privateKey + 明文 (原始資料) 經過 AES256 加密得出密文
                
                guard let pmOriginalData = String(data: pmData, encoding: .utf8)!.data(using: .utf8) else { return }
                
                guard let encrypted_pmData = cryptoManager.aes256Encrypted(clearText: pmOriginalData,
                                                                           privateKey: privateKey,
                                                                           iv: ivToString) else {
                    return
                }
                
                let combined = cryptoManager.combinedCipherTextAndPreIV(cipherText: encrypted_pmData,
                                                                        preIV: preIV)
                
                LocalDatabase.shared.insert(id: pm.id,userID: UserPreferences.shared.userID, cipherText: combined, table: .password)
            } dismiss: {
                if self.root == .chromeExtension {
                    self.delegate?.chromeExtensionAutoFillTableViewReloadData()
                    self.dismiss(animated: true)
                } else {
                    if UserPreferences.shared.isFirstAddPasswordOrNotes == false {
                        self.showFirstAddAlertDelegate?.showAlert()
                    }
                    self.popToRootViewController()
                }
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func hideOrShowTextFields(_ sender: UIButton) {
        switch sender.tag {
        case 0: // 按下顯示進階設定按鈕
            showView.isHidden = true
            hideView.isHidden = false
        case 1: // 按下隱藏進階設定按鈕
            showView.isHidden = false
            hideView.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func getNewPasswordBtnClicked(sender: UIButton) {
        let nextVC = GenerateRandomPasswordViewController()
        nextVC.delegate = self
        nextVC.isModalInPresentation = true
        self.present(nextVC, animated: true)
    }
    
    @IBAction func textFieldDidChanged(_ sender: UITextField) {
        guard let textFieldText = sender.text else {
            return
        }
        switch sender {
        case titleTextField:
            DispatchQueue.main.async {
                self.titleCountLabel.text = "\(textFieldText.count)/35"
            }
        case accountTextField:
            DispatchQueue.main.async {
                self.accountCountLabel.text = "\(textFieldText.count)/100"
            }
        case passwordTextField:
            DispatchQueue.main.async {
                self.passwordCountLabel.text = "\(textFieldText.count)/50"
            }
        case urlTextField:
            DispatchQueue.main.async {
                self.urlCountLabel.text = "\(textFieldText.count)/100"
            }
        default:
            break
        }
    }
}

// MARK: - NavigationBarViewDelegate

extension AddPasswordViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        saveButtonAction()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension AddPasswordViewController: UIAdaptivePresentationControllerDelegate {
    
    // 當手動將 present 出來的畫面下滑時，會觸發的 Delegate
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if (titleTextField.text == "" &&
            accountTextField.text == "" &&
            passwordTextField.text == "" &&
            noteTextView.text == "") {
            print("輸入框沒值")
            return true // 可以下滑關閉
        } else {
            return false // 不能下滑關閉
        }
    }
    
    // 當 presentationControllerShouldDismiss 或 isModalInPresentation 為 false 時，會觸發的 Delegate
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("輸入框有值")
        Alert.showAlertWith(title: translate(.Cancel_Add),
                            message: translate(.The_currently_entered_data_has_not_been_saved_Do_you_want_to_leave_this_screen),
                            vc: self,
                            confirmTitle: translate(.Confirm),
                            cancelTitle: translate(.Cancel),
                            confirm: {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        })
    }
}

// MARK: - GenerateRandomPasswordDelegate

extension AddPasswordViewController: GenerateRandomPasswordDelegate {
    
    func postNewGeneratePassword(newPassword: String) {
        DispatchQueue.main.async {
            self.receivePassword = newPassword
            self.passwordTextField.text = self.receivePassword
            self.passwordCountLabel.text = "\(newPassword.count)/50"
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddPasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        switch textField {
        case titleTextField:
            return count <= 35
        case accountTextField:
            return count <= 100
        case passwordTextField:
            return count <= 50
        case urlTextField:
            return count <= 100
        default:
            return true
        }
    }
}

// MARK: - UITextViewDelegate

extension AddPasswordViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard let textViewText = textView.text,
              let rangeOfTextToReplace = Range(range, in: textViewText) else {
            return false
        }
        
        let substringToReplace = textViewText[rangeOfTextToReplace]
        let count = textViewText.count - substringToReplace.count + text.count
        
        return count <= 100
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.notesCountLabel.text = "\(textView.text.count)/100"
        }
    }
}

// MARK: - Protocol

protocol AddPasswordViewControllerDelegate: NSObjectProtocol {
    
    func chromeExtensionAutoFillTableViewReloadData()
}

/*
 
 /// 客製化 NavigationBar
 
 https://stackoverflow.com/a/36730900
 
 navigationItem.backBarButtonItem：
 https://dmtopolog.com/navigation-bar-customization/
 
 Execute action when back bar button of UINavigationController is pressed：
 https://stackoverflow.com/a/27715660
 */
