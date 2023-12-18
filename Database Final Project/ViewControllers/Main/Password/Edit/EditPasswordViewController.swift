//
//  EditPasswordViewController.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/8/23.
//

import UIKit
import IQKeyboardManagerSwift

class EditPasswordViewController: BaseViewController {
    
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
    @IBOutlet var openUrlOrCopyButton: [UIButton]!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var accountCountLabel: UILabel!
    @IBOutlet weak var passwordCountLabel: UILabel!
    @IBOutlet weak var urlCountLabel: UILabel!
    @IBOutlet weak var notesCountLabel: UILabel!
    
    // MARK: - Variables
    
    var receivePassword: String = "" // 從安全密碼產生器傳過來的密碼
        
    var tmpTitle = SingletonPatternOfPasswordAndNotes.shared.title
    var tmpAccount = SingletonPatternOfPasswordAndNotes.shared.account
    var tmpPassword = SingletonPatternOfPasswordAndNotes.shared.password
    var tmpUrl = SingletonPatternOfPasswordAndNotes.shared.url
    var tmpNote = SingletonPatternOfPasswordAndNotes.shared.note
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        // passwordTextField.text = receivePassword
        
        // 若使用者沒編輯但按下儲存的按鈕
        if (tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title) &&
            (tmpAccount == SingletonPatternOfPasswordAndNotes.shared.account) &&
            (tmpPassword == SingletonPatternOfPasswordAndNotes.shared.password) &&
            (tmpUrl == SingletonPatternOfPasswordAndNotes.shared.url) &&
            (tmpNote == SingletonPatternOfPasswordAndNotes.shared.note) {
            setupSaveButtonType(buttonIsEnabled: false, buttonAlpha: 0.5)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SingletonPatternOfPasswordAndNotes.shared.title = ""
        SingletonPatternOfPasswordAndNotes.shared.account = ""
        SingletonPatternOfPasswordAndNotes.shared.password = ""
        SingletonPatternOfPasswordAndNotes.shared.url = ""
        SingletonPatternOfPasswordAndNotes.shared.note = ""
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupNavigationBarView() // 設定 NavigationBar 樣式
        setupTextFields() // 設定 TextField 樣式
        setupTextViewMode() // 設定 noteTextView 樣式
        setupRequiredLabels() // 設定`必填的Label`的多國語言
        
        // 設定 `顯示進階設定` 跟 `隱藏進階設定` 的按鈕樣式
        showAdvancedSettingsButton.setTitle(translate(.Show_Advanced_Settings), for: .normal)
        hideAdvancedSettingsButton.setTitle(translate(.Hide_Advanced_Settings), for: .normal)
        
        // 設定`產生新密碼` 底線樣式
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),             // 文字大小、字體樣式
            .foregroundColor: #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1) ,                            // 文字顏色
            .underlineStyle: NSUnderlineStyle.single.rawValue // .single.rawValue 單條底線 .double.rawValue .thick.rawValue 單條粗底線
        ]
        let getNewPasswordAttribute = NSMutableAttributedString(
            string: translate(.Get_New_Password),
            attributes: textAttributes
        )
        getNewPasswordButton.setAttributedTitle(getNewPasswordAttribute, for: .normal)
        getNewPasswordButton.isHidden = true
        // 設定 copyOrOpenUrlButton
        setupCopyOrOpenUrlButton()
        
        setInit(title: SingletonPatternOfPasswordAndNotes.shared.title,
                account: SingletonPatternOfPasswordAndNotes.shared.account,
                password: SingletonPatternOfPasswordAndNotes.shared.password,
                url: SingletonPatternOfPasswordAndNotes.shared.url,
                note: SingletonPatternOfPasswordAndNotes.shared.note)
        
        setupCountLabel() // 設定字數統計 Label 樣式
    }
    
    /// 設定進`編輯畫面`的值
    func setInit(title: String,
                 account: String,
                 password: String,
                 url: String,
                 note: String) {
        // setup text
        titleTextField.text = SingletonPatternOfPasswordAndNotes.shared.title
        accountTextField.text = SingletonPatternOfPasswordAndNotes.shared.account
        passwordTextField.text = SingletonPatternOfPasswordAndNotes.shared.password
        urlTextField.text = SingletonPatternOfPasswordAndNotes.shared.url.isEmpty ? translate(.URL) : SingletonPatternOfPasswordAndNotes.shared.url
        noteTextView.text = SingletonPatternOfPasswordAndNotes.shared.note.isEmpty ? translate(.Note) : SingletonPatternOfPasswordAndNotes.shared.note
        
        // setup textColor to be like placeholder
        titleTextField.textColor = .placeholderText
        accountTextField.textColor = .placeholderText
        passwordTextField.textColor = .placeholderText
        urlTextField.textColor = .placeholderText
        noteTextView.textColor = .placeholderText
    }
    
    /// 設定 NavigationBarView 樣式
    private func setupNavigationBarView() {
        vNavigationBar.delegate = self
        vNavigationBar.setInit(backButtonIsHidden: false,
                               backButtonImage: UIImage(icon: .back),
                               backButtonTitle: translate(.Edit),
                               displayMode: .leftRight,
                               btnIcon2: .save)
    }
    
    /// 設定字數統計 Label 樣式
    private func setupCountLabel() {
        titleCountLabel.text = "\(titleTextField.text!.count)/35"
        accountCountLabel.text = "\(accountTextField.text!.count)/100"
        passwordCountLabel.text = "\(passwordTextField.text!.count)/50"
        urlCountLabel.text = "\(urlTextField.text!.count)/100"
        notesCountLabel.text = "\(noteTextView.text.count)/100"
    }
    
    /// 設定 TextField 樣式
    private func setupTextFields() {
        titleTextField.delegate = self
        accountTextField.delegate = self
        passwordTextField.delegate = self
        urlTextField.delegate = self
    }
    
    /// 設定 noteTextView 樣式
    private func setupTextViewMode() {
        noteTextView.delegate = self
        noteTextView.layer.borderColor = UIColor.gray.cgColor
        noteTextView.layer.borderWidth = 2
        noteTextView.layer.cornerRadius = noteTextView.bounds.height / 10
        noteTextView.showsVerticalScrollIndicator = true // 垂直滾動指示器
        noteTextView.showsHorizontalScrollIndicator = false // 水平滾動指示器
    }
    
    /// 設定`必填的Label`的多國語言
    private func setupRequiredLabels() {
        requiredLabels[0].text = translate(.Required)
        requiredLabels[1].text = translate(.Required)
        requiredLabels[2].text = translate(.Required)
    }
    
    /// 設定 rightBarButtonItem 的儲存按鈕狀態
    private func setupSaveButtonType(buttonIsEnabled: Bool, buttonAlpha: CGFloat) {
        vNavigationBar.btnRight2.isEnabled = buttonIsEnabled
        vNavigationBar.btnRight2.tintColor = UIColor.white.withAlphaComponent(buttonAlpha)
    }
    
    /// 設定 copyOrOpenUrlButton 的按鈕狀態
    private func setupCopyOrOpenUrlButton() {
        openUrlOrCopyButton[0].setTitle("", for: .normal) // open url
        openUrlOrCopyButton[1].setTitle("", for: .normal) // copy
        openUrlOrCopyButton[2].setTitle("", for: .normal) // copy
        
        openUrlOrCopyButton[0].setImage(UIImage(icon: .share), for: .normal)
        openUrlOrCopyButton[1].setImage(UIImage(icon: .copy), for: .normal)
        openUrlOrCopyButton[2].setImage(UIImage(icon: .copy), for: .normal)
        
        openUrlOrCopyButton[0].tintColor = .black
        openUrlOrCopyButton[1].tintColor = .black
        openUrlOrCopyButton[2].tintColor = .black
    }
    
    // MARK: - Right NavigationBarItems Function
    
    /// 按下退回按鈕後要做的事 ...
    @objc func backButtonAction() {
        if (tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title) &&
            (tmpAccount == SingletonPatternOfPasswordAndNotes.shared.account) &&
            (tmpPassword == SingletonPatternOfPasswordAndNotes.shared.password) &&
            (tmpUrl == SingletonPatternOfPasswordAndNotes.shared.url) &&
            (tmpNote == SingletonPatternOfPasswordAndNotes.shared.note) {
            print("輸入框為空值")
            self.popViewController()
        } else {
            print("輸入框有值")
            Alert.showAlertWith(title: translate(.Cancel_Edit),
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
    
    /// 按下儲存按鈕後要做的事 ...
    @objc func saveButtonAction() {
        if (titleTextField.text == "" || accountTextField.text == "" || passwordTextField.text == "") {
            print("請確認必填欄位皆已輸入")
            Alert.showAlertWith(title: "",
                                message: translate(.Please_make_sure_all_required_fields_are_entered),
                                vc: self,
                                confirmTitle: translate(.Confirm),
                                confirm: nil)
        } else {
                Alert.showToastWith(message: translate(.Edit_Password_Succeed),
                                    vc: self,
                                    during: .long) { [unowned self] in
                    // 編輯密碼
                    let pm = PasswordModel(id: SingletonPatternOfPasswordAndNotes.shared.id,
                                           title: tmpTitle,
                                           account: tmpAccount,
                                           password: tmpPassword,
                                           url: tmpUrl,
                                           note: tmpNote)
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
                            
                    LocalDatabase.shared.update(id: pm.id, userID: UserPreferences.shared.userID, cipherText: combined, table: .password)
                } dismiss: { [unowned self] in
                    popToRootViewController()
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
        self.present(nextVC, animated: false)
    }
    
    @IBAction func copyNotes(_ sender: UIButton) {
        switch sender {
        case openUrlOrCopyButton[0]:
            // 開啟連結
            if let url = URL(string: urlTextField.text!) {
                if urlTextField.text!.contains("http") || urlTextField.text!.contains("https") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    let newURL = URL(string: "https://\(urlTextField.text!)")!
                    UIApplication.shared.open(newURL, options: [:], completionHandler: nil)
                }
            }
        case openUrlOrCopyButton[1]:
            // 複製密碼
            Alert.showAlertWith(title: translate(.Copy_Succeed),
                                message: translate(.Information_has_been_copied_to_the_scrapbook),
                                vc: self,
                                confirmTitle: translate(.Confirm)) {
                let board = UIPasteboard.general
                board.string = self.passwordTextField.text
            }
        case openUrlOrCopyButton[2]:
            // 複製帳號
            Alert.showAlertWith(title: translate(.Copy_Succeed),
                                message: translate(.Information_has_been_copied_to_the_scrapbook),
                                vc: self,
                                confirmTitle: translate(.Confirm)) {
                let board = UIPasteboard.general
                board.string = self.accountTextField.text
            }
        default:
            break
        }
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

extension EditPasswordViewController: NavigationBarViewDelegate {
    
    func btnBackClicked() {
        backButtonAction()
    }
    
    func btnRightClicked(index: Int) {
        saveButtonAction()
    }
}

// MARK: - GenerateRandomPasswordDelegate

extension EditPasswordViewController: GenerateRandomPasswordDelegate {
    
    func postNewGeneratePassword(newPassword: String) {
        DispatchQueue.main.async {
            self.receivePassword = newPassword
            self.passwordTextField.text = self.receivePassword
            self.passwordCountLabel.text = "\(newPassword.count)/50"
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditPasswordViewController: UITextFieldDelegate {
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case titleTextField:
            titleTextField.text = tmpTitle
            titleTextField.textColor = .black
        case accountTextField:
            accountTextField.text = tmpAccount
            accountTextField.textColor = .black
        case passwordTextField:
            passwordTextField.text = tmpPassword
            passwordTextField.textColor = .black
            getNewPasswordButton.isHidden = false
        case urlTextField:
            urlTextField.text = tmpUrl
            urlTextField.textColor = .black
        default:
            break
        }
        setupSaveButtonType(buttonIsEnabled: true, buttonAlpha: 1)
    }
    
    /// 標題 TextField 輸入完後，按空白處會執行的事
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case titleTextField:
            if titleTextField.text == SingletonPatternOfPasswordAndNotes.shared.title {
                titleTextField.textColor = .placeholderText
            }
            tmpTitle = titleTextField.text!
        case accountTextField:
            if accountTextField.text == SingletonPatternOfPasswordAndNotes.shared.account {
                accountTextField.textColor = .placeholderText
            }
            tmpAccount = accountTextField.text!
        case passwordTextField:
            if passwordTextField.text == SingletonPatternOfPasswordAndNotes.shared.password {
                passwordTextField.textColor = .placeholderText
            }
            tmpPassword = passwordTextField.text!
            getNewPasswordButton.isHidden = true
        case urlTextField:
            if urlTextField.text == SingletonPatternOfPasswordAndNotes.shared.url {
                urlTextField.textColor = .placeholderText
            }
            tmpUrl = urlTextField.text!
        default:
            break
        }
        
        // 若最後變更完值依然跟單例的值相同，rightBarButtonItem 的儲存鍵就不能按
        if (tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title &&
            tmpAccount == SingletonPatternOfPasswordAndNotes.shared.account &&
            tmpPassword == SingletonPatternOfPasswordAndNotes.shared.password &&
            tmpUrl == SingletonPatternOfPasswordAndNotes.shared.url &&
            tmpNote == SingletonPatternOfPasswordAndNotes.shared.note) {
            setupSaveButtonType(buttonIsEnabled: false, buttonAlpha: 0.5)
        }
    }
}

// MARK: - UITextViewDelegate

extension EditPasswordViewController: UITextViewDelegate {
    
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        noteTextView.text = tmpNote
        noteTextView.textColor = .black
        setupSaveButtonType(buttonIsEnabled: true, buttonAlpha: 1)
    }
    
    /// 備註 TextView 輸入完後，按空白處會執行的事
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text == SingletonPatternOfPasswordAndNotes.shared.note {
            noteTextView.textColor = .placeholderText
        }
        tmpNote = noteTextView.text!
        
        // 若最後變更完值依然跟單例的值相同，rightBarButtonItem 的儲存鍵就不能按
        if (tmpTitle == SingletonPatternOfPasswordAndNotes.shared.title &&
            tmpAccount == SingletonPatternOfPasswordAndNotes.shared.account &&
            tmpPassword == SingletonPatternOfPasswordAndNotes.shared.password &&
            tmpUrl == SingletonPatternOfPasswordAndNotes.shared.url &&
            tmpNote == SingletonPatternOfPasswordAndNotes.shared.note) {
            setupSaveButtonType(buttonIsEnabled: false, buttonAlpha: 0.5)
        }
    }
}
