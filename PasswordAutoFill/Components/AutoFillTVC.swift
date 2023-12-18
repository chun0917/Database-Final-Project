//
//  AutoFillTVC.swift
//  PasswordAutoFill
//
//  Created by 呂淳昇 on 2022/7/6.
//

import UIKit

class AutoFillTVC: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    // MARK: - Variables
    
    static let identifier = "AutoFillTVC"
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - UI Settings
    
    func setInit(title: String, detail: String, iconName: SFSymbols) {
        titleLabel.text = title
        detailLabel.text = detail
        leftIconImageView.image = UIImage(icon: iconName)
    }
}
