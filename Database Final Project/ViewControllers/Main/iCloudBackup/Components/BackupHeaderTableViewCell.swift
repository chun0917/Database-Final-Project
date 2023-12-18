//
//  BackupHeaderTableViewCell.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/20.
//

import UIKit

class BackupHeaderTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lastBackupTimeLabel: UILabel!
    
    // MARK: - Variables
    
    static let identifier = "BackupHeaderTableViewCell"
    
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
    
    func setInit(iCloudAvailable: Bool, backupTime: String) {
        let iconName: SFSymbols = iCloudAvailable ? .icloudAvailable : .icloudUnavailable
        iconImageView.image = UIImage(icon: iconName)
        lastBackupTimeLabel.text = backupTime
    }
}
