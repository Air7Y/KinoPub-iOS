//
//  KPManager.swift
//  KinoPub
//
//  Created by Евгений Дац on 21/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation

public class KPManager {
    public static let shared = KPManager()
    
    private let requestFactory: KPRequestFactory
    private let networkingService: KPNetworkingService
    
    init() {
        requestFactory = KPRequestFactory()
        networkingService = KPNetworkingService(requestFactory: requestFactory)
    }
    
    public func load(_ method: KPMethods, with kpID: String, completed: @escaping (_ data: KPData?, _ error: Error?) -> ()) {
        networkingService.receiveFromKpWithMethod(kpID, method: method) { (response, error) in
            if let response = response {
                completed(response.kpData, nil)
            }
        }
    }
    
    public func getFullImageUrl(for url: String) -> String {
        return "\(Config.kinopoisk.Poster.gallery)\(url)".replacingOccurrences(of: "iphone_", with: "iphone360_")
    }
}
