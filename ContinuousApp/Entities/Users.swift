//
//  Users.swift
//  ContinuousApp
//
//  Copyright © 2018 AppTrix AB. All rights reserved.
//

import Foundation

struct Users: Codable {
  let total: Int
  let page: Int
  let user: [User]
  let perPage: Int
  let totalPages: Int

  enum CodingKeys: String, CodingKey {
    case total
    case page
    case user = "data"
    case perPage = "per_page"
    case totalPages = "total_pages"
  }
}

struct User: Codable {
  let avatar: String
  let lastName: String
  let id: Int
  let firstName: String

  enum CodingKeys: String, CodingKey {
    case id
    case avatar
    case lastName = "last_name"
    case firstName = "first_name"
  }
}
