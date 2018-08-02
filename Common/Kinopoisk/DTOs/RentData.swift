//
//  RentData.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct RentData : Mappable {
	var premiereRU : String?
	var distributors : String?
	var premiereWorld : String?
	var premiereWorldCountry : String?
	var premiereDigital : String?
	var digitalDistributor : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		premiereRU <- map["premiereRU"]
		distributors <- map["Distributors"]
		premiereWorld <- map["premiereWorld"]
		premiereWorldCountry <- map["premiereWorldCountry"]
		premiereDigital <- map["premiereDigital"]
		digitalDistributor <- map["digitalDistributor"]
	}

}
