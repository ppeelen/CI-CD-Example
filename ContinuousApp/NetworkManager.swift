//
//  NetworkManager.swift
//  ContinuousApp
//
//  Copyright © 2018 AppTrix AB. All rights reserved.
//

import Foundation

protocol NetworkManaging {
  func get<T: Decodable>(endpoint: String, completionHandler: @escaping ((Result<T>) -> Void)) -> URLSessionDataTask?
}

enum NetworkHandlerError: Error, CustomStringConvertible {
  case invalidData
  case apiReponseUnhandledStatusCode(statusCode: Int)

  var description: String {
    switch self {
      case .invalidData:
        return "The data returned by the API was deemed invalid."
      case .apiReponseUnhandledStatusCode(let statusCode):
        return "An invalid statuscode (\(statusCode)) was returned by the API."
    }
  }
}

class NetworkManager {

  let baseUrlString: String

  private let urlSession: URLSession
  private let headers: [String: String] = {
    return [
      "Content-Type"         : "application/json",
      "Accept-Language"      : "sv-se",
      "Accept-Encoding"      : "gzip, deflate",
      "Accept"               : "*/*"
    ]
  }()

  init(baseUrl: String? = nil, urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
    self.baseUrlString = baseUrl ?? "https://reqres.in/api/"
  }
}

extension NetworkManager : NetworkManaging {

  //MARK: Public

  func get<T: Decodable>(endpoint: String, completionHandler: @escaping ((Result<T>) -> Void)) -> URLSessionDataTask? {

    let completionHandlerOnMain: ((Result<T>) -> Void) = { (result) in
      DispatchQueue.main.async {
        completionHandler(result)
      }
    }

    guard let url = URL(string: baseUrlString + endpoint) else { return nil }

    return request(url: url) { (data, response, error) in
      if let error = error {
        completionHandlerOnMain(.failure(error))
        return
      }

      if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode >= 400 {
        completionHandlerOnMain(.failure(NetworkHandlerError.apiReponseUnhandledStatusCode(statusCode: urlResponse.statusCode)))
        return
      }

      guard let data = data else {
        completionHandlerOnMain(.failure(NetworkHandlerError.invalidData))
        return
      }

      let jsonResult = self.decodeJson(data: data) as Result<T>
      completionHandlerOnMain(jsonResult)
    }
  }

  //MARK: Private

  private func request(url: URL, completionHandler: @escaping ((Data?, URLResponse?, Error?)->Void)) -> URLSessionDataTask {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    headers.forEach { (fieldName, value) in
      request.setValue(value, forHTTPHeaderField: fieldName)
    }

    let task = urlSession.dataTask(with: request, completionHandler: completionHandler)
    task.resume()

    return task
  }

  private func decodeJson<T: Decodable>(data: Data) -> Result<T> {
    let decoder = JSONDecoder()
    do {
      let model: T = try decoder.decode(T.self, from: data)
      return .success(model)
    } catch {
      return .failure(error)
    }
  }
}
