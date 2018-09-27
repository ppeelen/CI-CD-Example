//
//  DataBoss.swift
//  ContinuousApp
//
//  Copyright © 2018 AppTrix AB. All rights reserved.
//

import Foundation



class DataBoss {

  private var networkManager: NetworkManaging

  private var getAllUsersTask: URLSessionDataTask?

  init(networkManager: NetworkManaging = NetworkManager()) {
    self.networkManager = networkManager
  }

  func getAllUsers(completion: @escaping ([User]?, Error?)->Void) {
    getAllUsersTask?.cancel()

    getAllUsersTask = networkManager.get(endpoint: "users?page=2", completionHandler: { (result: Result<Users>) in
      if let users = result.value {
        completion(users.user, nil)
      } else {
        completion(nil, result.error)
      }
    })
  }
}
