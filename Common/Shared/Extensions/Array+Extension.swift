//
//  Array+Extension.swift
//  KinoPub
//
//  Created by Евгений Дац on 20/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    var uniqued: Array {
        var buffer = [Element]()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    mutating func unique() {
        self = uniqued
    }
}
