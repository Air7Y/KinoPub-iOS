//
//  NetworkingService.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class KPNetworkingService {
    var requestFactory: KPRequestFactory
    
    init(requestFactory: KPRequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveFromKpWithMethod(_ id: String, method: KPMethods, completed: @escaping (_ responseObject: KPResponse?, _ error: Error?) -> ()) {
        requestFactory.receiveWithMethodRequest(id, method: method).validate()
            .responseObject { (response: DataResponse<KPResponse>) in
                switch response.result {
                case .success:
                    if response.response?.statusCode == 200 {
                        completed(response.result.value, nil)
                    }
                case .failure(let error):
                    completed(nil, error)
                }
        }
    }
}
