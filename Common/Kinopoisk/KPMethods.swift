//
//  KPMethods.swift
//  KinoPub
//
//  Created by Евгений Дац on 20/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation

public struct KPMethod: Equatable, ExpressibleByStringLiteral {
    var method = "method"
    var id = "id"
    
    public static func == (lhs: KPMethod, rhs: KPMethod) -> Bool {
        return lhs.method == rhs.method
    }
    
    public init(stringLiteral value: String) {
        let components = value.components(separatedBy: ",")
        if components.count == 2 {
            self.method = components[0]
            self.id = components[1]
        }
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

public enum KPMethods: KPMethod {
    case filmDetail = "getKPFilmDetailView,filmID"
    case staffList = "getStaffList,filmID"
    case peopleDetail = "getKPPeopleDetailView,peopleID"
}
