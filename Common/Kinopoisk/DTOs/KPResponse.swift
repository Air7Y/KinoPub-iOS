//
//  KPResponse.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct KPResponse : Mappable {
	var resultCode : Int?
	var message : String?
	var kpData : KPData?
	var no_cache_flag : Bool?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		resultCode <- map["resultCode"]
		message <- map["message"]
		kpData <- map["data"]
		no_cache_flag <- map["no_cache_flag"]
	}

}
