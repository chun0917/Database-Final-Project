//
//  String+Extensions.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/10/11.
//

import Foundation

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    func asDictionary() throws -> [String : String] {
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? [String : String] else {
            throw NSError()
        }
        
        return dictionary
    }
    
    func base64urlToBase64() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
    
    func base64ToBase64url() -> String {
        var base64url = self
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        if base64url.count % 4 != 0 {
            base64url.append(String(repeating: "=", count: 4 - base64url.count % 4))
        }
        return base64url
    }
    
    /// Base64  解碼失敗 Error enum
    enum Base64DecodeError: Error {
        
        /// 解碼失敗
        case decodeFailed
        
        /// 字串 UTF8 編碼失敗
        case stringUTF8EncodeFailed
    }
    
    func base64Decoded() throws -> String {
        guard let data = Data(base64Encoded: self) else {
            throw Base64DecodeError.decodeFailed
        }
        
        guard let result = String(data: data, encoding: .utf8) else {
            throw Base64DecodeError.stringUTF8EncodeFailed
        }
        
        return result
    }
}
