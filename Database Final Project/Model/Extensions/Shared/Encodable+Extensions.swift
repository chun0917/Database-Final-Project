//
//  Encodable+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/2.
//

import Foundation

extension Encodable {
    
    /// 將 Encodable 轉換成 Dictionary<String, Any>
    func asDictionary() throws -> [String : Any] {
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? [String : Any] else {
            throw NSError()
        }
        
        return dictionary
    }
    
    /// 將 Encodable 轉換成 Dictionary<String, String>
    func asStringDictionary() throws -> [String : String] {
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? [String : String] else {
            throw NSError()
        }
        
        return dictionary
    }
}
