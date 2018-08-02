//
//  KPData.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct KPData : Mappable {
    var kpClass : String?
	var hasSimilarFilms : Int?
	var reviewsCount : Int?
	var ratingData : RatingData?
	var hasRelatedFilms : Int?
	var filmID : Int?
	var webURL : String?
	var nameRU : String?
	var type : String?
	var nameEN : String?
	var posterURL : String?
	var posterSize : PosterSize?
	var bigPosterURL : String?
	var year : String?
	var filmLength : String?
	var country : String?
	var genre : String?
	var slogan : String?
	var description : String?
	var videoURL : VideoURL?
	var ratingMPAA : String?
	var isIMAX : Int?
	var is3D : Int?
	var ratingAgeLimits : String?
	var rentData : RentData?
	var budgetData : BudgetData?
	var gallery : [Gallery]?
	var creators : [[Creators]]?
	var topNewsByFilm : TopNewsByFilm?
	var triviaData : [String]?
	var musicAdvert : String?

    public init?(map: Map) {

	}

    public mutating func mapping(map: Map) {

		kpClass <- map["class"]
		hasSimilarFilms <- map["hasSimilarFilms"]
		reviewsCount <- map["reviewsCount"]
		ratingData <- map["ratingData"]
		hasRelatedFilms <- map["hasRelatedFilms"]
		filmID <- map["filmID"]
		webURL <- map["webURL"]
		nameRU <- map["nameRU"]
		type <- map["type"]
		nameEN <- map["nameEN"]
		posterURL <- map["posterURL"]
		posterSize <- map["posterSize"]
		bigPosterURL <- map["bigPosterURL"]
		year <- map["year"]
		filmLength <- map["filmLength"]
		country <- map["country"]
		genre <- map["genre"]
		slogan <- map["slogan"]
		description <- map["description"]
		videoURL <- map["videoURL"]
		ratingMPAA <- map["ratingMPAA"]
		isIMAX <- map["isIMAX"]
		is3D <- map["is3D"]
		ratingAgeLimits <- map["ratingAgeLimits"]
		rentData <- map["rentData"]
		budgetData <- map["budgetData"]
		gallery <- map["gallery"]
		creators <- map["creators"]
		topNewsByFilm <- map["topNewsByFilm"]
		triviaData <- map["triviaData"]
		musicAdvert <- map["musicAdvert"]
	}

}
