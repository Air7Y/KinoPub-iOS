//
//  LogManager.swift
//  qinoa
//
//  Created by Евгений Дац on 10.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import Crashlytics

class LogManager {
    static let shared = LogManager()
    
    func log(_ format: String, _ ap: CVaListPointer) {
        CLSLogv(format, ap)
    }
}
