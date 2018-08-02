//
//  PosterSize.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct PosterSize : Mappable {
	var s360 : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		s360 <- map["360"]
	}

}
