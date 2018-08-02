//
//  KPUtils.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import CryptoSwift

public class KPUtils {
    static var timestamp: String {
        return String(Date().timeIntervalSince1970)
    }
    
    static var clientDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "yyyy MMMM dd"
        return formatter.string(from: Date())
    }
    
    static func md5(_ string: String) -> String {
        return string.md5()
    }
}
