//
//  CommentsNetworkingService.swift
//  qinoa
//
//  Created by Евгений Дац on 28.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class CommentsNetworkingService {
    var requestFactory: RequestFactory
    
    init(requestFactory: RequestFactory) {
        self.requestFactory = requestFactory
    }
    
    func receiveComments(id: String, completed: @escaping (_ responseObject: CommentsResponse?, _ error: Error?) -> Void) {
        requestFactory.receiveCommentsRequest(id: id)
            .validate()
            .responseObject { (response: DataResponse<CommentsResponse>) in
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
