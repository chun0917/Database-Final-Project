//
//  CheckBoxButtonView.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/12/9.
//

import UIKit

class CheckBoxButtonView: UIView {

    // MARK: - IBOutlet
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Variables
    
    weak var delegate: CheckBoxButtonViewDelegate?
    
    let checkedImage = UIImage(icon: .checked)
    let uncheckedImage = UIImage(icon: .unchecked)
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                imageView.image = checkedImage
                imageView.tintColor = .navigationBar
            } else {
                imageView.image = uncheckedImage
                imageView.tintColor = .lightGray
            }
        }
    }
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        addXibView()
    }
    
    // view 在設計時想要看到畫面要用這個
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        addXibView()
    }
    
    // MARK: - UI Settings
    
    /// CheckBoxButtonView UI 初始化
    /// - Parameters:
    ///   - index: Int，UIButton 的 tag，判斷是點擊哪一個
    ///   - isChecked: Bool，預設是否勾選
    ///   - labelText: String，UIButton 的 Title，用 UILabel 來取代
    ///   - textColor: UIColor，UILabel 的文字顏色，預設為 UIColor.black
    ///   - delegate: CheckBoxButtonViewDelegate
    func setInit(index: Int,
                 isChecked: Bool,
                 labelText: String,
                 textColor: UIColor = .black,
                 delegate: CheckBoxButtonViewDelegate) {
        button.setTitle("", for: .normal)
        button.tag = index
        
        self.isChecked = isChecked
        
        label.text = labelText
        label.textColor = textColor
        
        self.delegate = delegate
    }
    
    // MARK: - IBAction
    
    @IBAction func btnClicked(_ sender: UIButton) {
        isChecked.toggle()
        delegate?.checkBox(sender, didClickAt: sender.tag)
    }
}

// MARK: - Extensions

fileprivate extension CheckBoxButtonView {
    // 加入畫面
    func addXibView() {
        guard let loadView = Bundle(for: CheckBoxButtonView.self).loadNibNamed("CheckBoxButtonView", owner: self)?.first as? UIView else {
            return
        }
        addSubview(loadView)
        loadView.frame = bounds
    }
}

// MARK: - Protocol

protocol CheckBoxButtonViewDelegate: NSObjectProtocol {
    
    func checkBox(_ checkBox: UIButton, didClickAt index: Int)
}
