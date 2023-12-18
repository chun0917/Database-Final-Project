//
//  iCloudEntity.swift
//  Database Final Project
//  Created by 呂淳昇 on 2023/2/3.
//

import Foundation
import CloudKit

struct PasswordTable {
    
    var recordID: CKRecord.ID? // CloudKit Database 上的 ID
    
    var id: String // LocalDatabase 內的 SQL ID
    
    var cipherText: String // 密文
    
    init(recordID: CKRecord.ID? = nil, id: String, cipherText: String) {
        self.recordID = recordID
        self.id = id
        self.cipherText = cipherText
    }
}

struct NotesTable {
    
    var recordID: CKRecord.ID? // CloudKit Database 上的 ID
    
    var id: String // LocalDatabase 內的 SQL ID
    
    var cipherText: String // 密文
    
    init(recordID: CKRecord.ID? = nil, id: String, cipherText: String) {
        self.recordID = recordID
        self.id = id
        self.cipherText = cipherText
    }
}
