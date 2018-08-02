//
//  KPRequestFactory.swift
//  KinoPub
//
//  Created by Евгений Дац on 20/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import Alamofire

class KPRequestFactory {
    let baseAPIURL: String
    let requestHeaders: HTTPHeaders
    
    init() {
        baseAPIURL = Config.kinopoisk.base
        requestHeaders = [
            "Image-Scale" : "1",
            "countryID" : "2",
            "Content-Lang" : "ru",
            "Accept" : "application/json",
            "User-Agent" : Config.kinopoisk.userAgent,
            "device" : Config.kinopoisk.device,
            "Android-Api-Version" : Config.kinopoisk.androidApiVersion
        ]
    }
    
    func receiveWithMethodRequest(_ id: String, method: KPMethods) -> DataRequest {
        let timestamp = KPUtils.timestamp
        let signature = "\(method.rawValue.method)?\(method.rawValue.id)=\(id)\(timestamp)\(Config.kinopoisk.salt)"
        let parameters = [
            method.rawValue.id : id
        ]
        var headers = [
            "clientDate" : KPUtils.clientDate,
            "X-SIGNATURE" : KPUtils.md5(signature),
            "X-TIMESTAMP" : timestamp
        ]
        headers.unionInPlace(requestHeaders)
        let requestUrl = baseAPIURL + method.rawValue.method
        return Alamofire.request(requestUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
    }
}
