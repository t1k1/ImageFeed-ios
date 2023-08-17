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
    private func data(
        for request: URLRequest,
        completion: @escaping (Result<Data,Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompleteon: (Result<Data,Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
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
    
    /// Запрос и обработка ответа от сервера
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return data(for: request) { (result: Result<Data,Error>) in
            let response = result.flatMap { data -> Result<T, Error> in
                Result {
                    try decoder.decode(T.self, from: data)
                }
                
            }
            completion(response)
        }
    }
}
