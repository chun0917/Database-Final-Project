//
//  PasswordMainTableViewCell.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/1.
//

import UIKit

class PasswordMainTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    // MARK: - Variables
    
    static let identifier = "PasswordMainTableViewCell"
    
    weak var delegate: PasswordMainTableViewCellDelegate?
    
    var index = 0
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMenu()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - UI Initial Setup
    
    /// 密碼頁面的 UI 樣式設定
    /// - Parameters:
    ///   - title: 密碼紀錄的標題
    ///   - account: 密碼紀錄的帳號
    ///   - buttonShowMenu: Button 是否顯示 UIMenu，預設為 true
    ///   - delegate: PasswordMainTableViewCellDelegate
    func setupUI(title: String,
                 account: String,
                 buttonShowMenu: Bool = true,
                 index: Int,
                 delegate: PasswordMainTableViewCellDelegate) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        accountLabel.text = account
        setupMoreButton(buttonTitle: " ",
                        buttonImageName: .threeDot,
                        showMenu: buttonShowMenu)
        self.index = index
        self.delegate = delegate
    }
    
    /// 設定 `三個點 Button` 的 Button 樣式
    /// - Parameters:
    ///   - buttonTitle: Button 文字標題，預設為 nil
    ///   - buttonImageName: [enum SFSymbols](x-source-tag://SFSymbols)，Button 圖片名稱
    ///   - showMenu: Button 是否顯示 UIMenu，預設為 true
    private func setupMoreButton(buttonTitle: String? = nil,
                                 buttonImageName: SFSymbols,
                                 showMenu: Bool = true) {
        moreButton.setTitle(buttonTitle, for: .normal)
        moreButton.setImage(UIImage(icon: buttonImageName), for: .normal)
        moreButton.showsMenuAsPrimaryAction = showMenu
        moreButton.isUserInteractionEnabled = true
        moreButton.transform = CGAffineTransform(rotationAngle: .pi/2)
    }
    
    /// 設定點`三個點 Button 產生的 UIMenu` 的樣式
    /// - Parameters:
    ///   - detailsAction: 詳細資料
    ///   - deleteAction: 刪除
    private func setupMenu() {
        let detailsAction = UIAction(title: translate(.Details),
                                     image: UIImage(icon: .edit)) { action in
            print("UIMenu Details")
            self.delegate?.btnClicked(buttonType: .detail, index: self.index)
        }
        
        let deleteAction = UIAction(title: translate(.Delete),
                                    image: UIImage(icon: .trash),
                                    attributes: .destructive) { action in
            print("UIMenu Delete")
            self.delegate?.btnClicked(buttonType: .delete, index: self.index)
        }
        
        let menu = UIMenu(children: [detailsAction, deleteAction])
        moreButton.menu = menu
    }
}

// MARK: - PasswordMainTableViewCellListener

protocol PasswordMainTableViewCellDelegate: NSObjectProtocol {

    /// 按下 moreButton 後要做的事
    func btnClicked(buttonType: AppDefine.MainMoreButtonMenu, index: Int)
}
