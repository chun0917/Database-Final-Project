//
//  Date+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/24.
//

import Foundation
extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
