//
//  Gallery.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Gallery : Mappable {
	var preview : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		preview <- map["preview"]
	}

}
