//
//  VideoURL.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct VideoURL : Mappable {
	var hd : String?
	var sd : String?
	var low : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		hd <- map["hd"]
		sd <- map["sd"]
		low <- map["low"]
	}

}
