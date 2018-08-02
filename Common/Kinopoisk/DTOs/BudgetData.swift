//
//  BudgetData.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct BudgetData : Mappable {
	var grossRU : String?
	var budget : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		grossRU <- map["grossRU"]
		budget <- map["budget"]
	}

}
