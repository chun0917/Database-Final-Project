//
//  BackupTableViewCell.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/21.
//

import UIKit

class BackupTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Variables
    
    static let identifier = "BackupTableViewCell"
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UI Settings
    
    func setInit(title: String, color: UIColor) {
        label.text = title
        label.textColor = color
    }
}
