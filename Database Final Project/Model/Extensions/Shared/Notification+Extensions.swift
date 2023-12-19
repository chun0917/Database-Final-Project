//
//  Notification+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/2.
//

import Foundation

extension Notification.Name {
    
    static let statusAutoFill = Notification.Name("statusAutoFill")
    
    static let kApplicationDidIdle5MinsNotification = Notification.Name("kApplicationDidIdle5MinsNotification")
    
    static let Extension_AccountIsEmptyString = Notification.Name("Extension_AccountIsEmptyString")
    
    static let Extension_PasswordIsEmptyString = Notification.Name("Extension_PasswordIsEmptyString")
    
    static let showInvaildQRCodeFormatAlert = Notification.Name("showInvaildQRCodeFormatAlert")
}
