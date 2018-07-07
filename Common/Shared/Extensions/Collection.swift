//
//  Collection.swift
//  qinoa
//
//  Created by Евгений Дац on 26.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
