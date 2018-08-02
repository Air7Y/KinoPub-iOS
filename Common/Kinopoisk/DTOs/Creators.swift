//
//  Creators.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Creators : Mappable {
	var id : String?
	var type : String?
	var nameRU : String?
	var nameEN : String?
	var posterURL : String?
	var professionText : String?
	var professionKey : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		id <- map["id"]
		type <- map["type"]
		nameRU <- map["nameRU"]
		nameEN <- map["nameEN"]
		posterURL <- map["posterURL"]
		professionText <- map["professionText"]
		professionKey <- map["professionKey"]
	}

}
