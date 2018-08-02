//
//  RatingData.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import ObjectMapper

public struct RatingData : Mappable {
	var ratingGoodReview : String?
	var ratingGoodReviewVoteCount : Int?
	var rating : String?
	var ratingVoteCount : String?
	var ratingAwait : String?
	var ratingAwaitCount : String?
	var ratingIMDb : String?
	var ratingIMDbVoteCount : String?
	var ratingFilmCritics : String?
	var ratingFilmCriticsVoteCount : String?
	var ratingRFCritics : String?
	var ratingRFCriticsVoteCount : Int?

	public init?(map: Map) {

	}

	public mutating func mapping(map: Map) {

		ratingGoodReview <- map["ratingGoodReview"]
		ratingGoodReviewVoteCount <- map["ratingGoodReviewVoteCount"]
		rating <- map["rating"]
		ratingVoteCount <- map["ratingVoteCount"]
		ratingAwait <- map["ratingAwait"]
		ratingAwaitCount <- map["ratingAwaitCount"]
		ratingIMDb <- map["ratingIMDb"]
		ratingIMDbVoteCount <- map["ratingIMDbVoteCount"]
		ratingFilmCritics <- map["ratingFilmCritics"]
		ratingFilmCriticsVoteCount <- map["ratingFilmCriticsVoteCount"]
		ratingRFCritics <- map["ratingRFCritics"]
		ratingRFCriticsVoteCount <- map["ratingRFCriticsVoteCount"]
	}

}
