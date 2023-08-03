//
//  URLRequest+Extensions.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.08.2023.
//

import Foundation

extension URLRequest {
    /// Вспомогательная функция для создания HTTP запроса
    //    static func makeHTTPRequest(
    //        path: String,
    //        httpMethod: String,
    //        host: String = "api.unsplash.com"
    //    ) -> URLRequest {
    //        
    //        var urlComponents = URLComponents()
    //        urlComponents.scheme = "https"
    //        urlComponents.host = host
    //        urlComponents.path = path
    //        let url = urlComponents.url!
    //        
    //        var request = URLRequest(url: url)
    //        request.httpMethod = httpMethod
    //        return request
    //    }
    
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
