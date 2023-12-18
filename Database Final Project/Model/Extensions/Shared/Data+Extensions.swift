//
//  Data+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/11.
//

import Foundation

extension Data {
    
    /// Hexadecimal string representation of `Data` object.
    
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
    
    func asDictionary() throws -> [String : String] {
        
        guard let dictionary = try JSONSerialization.jsonObject(with: self,
                                                                options: .allowFragments) as? [String : String] else {
            throw NSError()
        }
        
        return dictionary
    }
}
