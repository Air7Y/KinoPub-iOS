//
//  TopNewsByFilm.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct TopNewsByFilm : Mappable {
	var iD : String?
	var newsDate : String?
	var newsImagePreviewURL : String?
	var newsTitle : String?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		iD <- map["ID"]
		newsDate <- map["newsDate"]
		newsImagePreviewURL <- map["newsImagePreviewURL"]
		newsTitle <- map["newsTitle"]
	}

}
