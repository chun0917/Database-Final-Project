//
//  SFSymbols.swift
//  Database Final Project
//  Created by 呂淳昇 on 2022/12/19.
//

import Foundation

/// enum SFSymbols，App 中有使用到的原生 SF Symbols icon
/// - Tag: SFSymbols
enum SFSymbols {
    
    /// SF Symbols icon 名稱：checkmark.square.fill
    case checked
    
    /// SF Symbols icon 名稱：square
    case unchecked
    
    /// SF Symbols icon 名稱：eye.fill
    case openEye
    
    /// SF Symbols icon 名稱：eye.slash.fill
    case closeEye
    
    /// SF Symbols icon 名稱：chevron.backward
    case back
    
    /// SF Symbols icon 名稱：checkmark
    case checkmark
    
    /// SF Symbols icon 名稱：plus
    case plus
    
    /// SF Symbols icon 名稱：lock.fill
    case lock
    
    /// SF Symbols icon 名稱：magnifyingglass
    case magnifyingglass
    
    /// SF Symbols icon 名稱：qrcode.viewfinder
    case qrcode
    
    /// SF Symbols icon 名稱：square.and.pencil
    case edit
    
    /// SF Symbols icon 名稱：trash.fill
    case trash
    
    /// SF Symbols icon 名稱：key.fill
    case key
    
    /// SF Symbols icon 名稱：note.text
    case notes
    
    /// SF Symbols icon 名稱：gear
    case settings
    
    /// SF Symbols icon 名稱：rectangle.portrait.on.rectangle.portrait
    case copy
    
    /// SF Symbols icon 名稱：xmark
    case close
    
    /// SF Symbols icon 名稱：ellipsis
    case threeDot
    
    /// SF Symbols icon 名稱：sdcard.fill
    case save
    
    /// SF Symbols icon 名稱：square.and.arrow.up
    case share
    
    /// SF Symbols icon 名稱：icloud.and.arrow.up
    case icloudAvailable
    
    /// SF Symbols icon 名稱：xmark.icloud
    case icloudUnavailable
    
    /// SF Symbols icon 名稱：icloud.fill
    case icloud
    
    /// SF Symbols icon 名稱：info.circle.fill
    case info
    
    /// SF Symbols icon 名稱：faceid
    case faceid
    
    /// SF Symbols icon 名稱：touchid
    case touchid
    
    /// SF Symbols icon 名稱：arrow.forward.square.fill
    case rightChevronWithBackground
    
    /// SF Symbols icon 名稱：person.fill
    case person
    
    /// SF Symbols icon 名稱：cart.fill
    case appStore
    
    var imageName: String {
        switch self {
        case .checked:
            return "checkmark.square.fill"
        case .unchecked:
            return "square"
        case .openEye:
            return "eye.fill"
        case .closeEye:
            return "eye.slash.fill"
        case .back:
            return "chevron.backward"
        case .checkmark:
            return "checkmark"
        case .plus:
            return "plus"
        case .lock:
            return "lock.fill"
        case .magnifyingglass:
            return "magnifyingglass"
        case .qrcode:
            return "qrcode.viewfinder"
        case .edit:
            return "square.and.pencil"
        case .trash:
            return "trash.fill"
        case .key:
            return "key.fill"
        case .notes:
            return "note.text"
        case .settings:
            return "gear"
        case .copy:
            return "rectangle.portrait.on.rectangle.portrait"
        case .close:
            return "xmark"
        case .threeDot:
            return "ellipsis"
        case .save:
            return "sdcard.fill"
        case .share:
            return "square.and.arrow.up"
        case .icloudAvailable:
            return "icloud.and.arrow.up"
        case .icloudUnavailable:
            return "xmark.icloud"
        case .faceid:
            return "faceid"
        case .touchid:
            return "touchid"
        case .icloud:
            return "icloud.fill"
        case .info:
            return "info.circle.fill"
        case .rightChevronWithBackground:
            return "arrow.forward.square.fill"
        case .person:
            return "person.fill"
        case .appStore:
            return "cart.fill"
        }
    }
}
