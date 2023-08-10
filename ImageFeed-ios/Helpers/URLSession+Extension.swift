//
//  URLSession+Extension.swift
//  ImageFeed-ios
//
//  Created by Aleksey Kolesnikov on 03.08.2023.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    
    /// Вспомогательный метод для выполнения сетевого запроса
    func data(
        for request: URLRequest,
        complition: @escaping (Result<Data,Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompleteon: (Result<Data,Error>) -> Void = { result in
            DispatchQueue.main.async {
                complition(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    print(String(data: data, encoding: .utf8)!)
                    fulfillCompleteon(.success(data))
                } else {
                    fulfillCompleteon(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompleteon(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompleteon(.failure(NetworkError.urlSessionError))
            }
        }
        
        task.resume()
        return task
    }
}
