//
//  CommandBase.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/7/3.
//

import UIKit

class CommandBase: NSObject {
    
    static let sharedInstance = CommandBase()

    // MARK: - DateFormatter
    
    /// DateFormatter 將時間戳轉換成需要的時間格式
    /// - Parameters:
    ///   - timestamp: 時間戳
    ///   - needFormat: 需要轉換出來的時間格式
    /// - Returns: 轉換完成的時間格式字串
    func dateformatter(timestamp: Int64, needFormat: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = needFormat
        let str = formatter.string(from: date)
        
        return str
    }
    
    // MARK: - UIApplication Open URL
    
    /// 開啟指定的 URL
    /// - Parameters:
    ///   - url: URL 字串
    func openURL(with url: String) {
        guard let url = URL(string: url) else {
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url) { _ in }
    }
}
