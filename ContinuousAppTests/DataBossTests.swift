//
//  DataBossTests.swift
//  ContinuousAppTests
//
//  Created by Paul Peelen on 2018-09-27.
//  Copyright © 2018 AppTrix AB. All rights reserved.
//

import XCTest
@testable import ContinuousApp

class DataBossTests: XCTestCase {

  var sut: DataBoss!

  private var networkManagerMock: NetworkManagerMock!

  override func setUp() {

    networkManagerMock = NetworkManagerMock()

    sut = DataBoss(networkManager: networkManagerMock)
  }

  override func tearDown() {
    networkManagerMock = nil
    sut = nil
  }

  func testGetAllUsers_hasUsers_shouldReturnUsers() {
    let expectation = XCTestExpectation(description: "Validate that the users are fetched")

    let userOne = User(avatar: "", lastName: "Appleseed", id: 1, firstName: "John")
    let users = Users(total: 1, page: 1, user: [userOne], perPage: 1, totalPages: 1)

    networkManagerMock.getSuccessResult = users

    sut.getAllUsers { (users, error) in
      XCTAssertEqual(self.networkManagerMock.getInvokeCount, 1)

      XCTAssertEqual(users?.count, 1)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }

  func testGetAllUsers_error_shouldReturnError() {
    let expectation = XCTestExpectation(description: "Validate that we get an error")

    networkManagerMock.getErrorResult = NetworkManagerMockError.dummyError

    sut.getAllUsers { (users, error) in
      XCTAssertEqual(self.networkManagerMock.getInvokeCount, 1)
      XCTAssertNil(users)

      guard let error = error as? NetworkManagerMockError else {
        return XCTFail("Incorrect error returned")
      }
      XCTAssertEqual(error, NetworkManagerMockError.dummyError)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
  }
}

enum NetworkManagerMockError : Error {
  case unknown
  case dummyError
}

extension NetworkManagerMockError : Equatable { }

private class NetworkManagerMock: NetworkManaging{

  var getInvokeCount = 0
  var getEndpoint: String = ""
  var getReturnValue: URLSessionDataTask?

  var getSuccessResult: Users?
  var getErrorResult: Error?

  func get<T>(endpoint: String, completionHandler: @escaping ((Result<T>) -> Void)) -> URLSessionDataTask? where T : Decodable {
    getInvokeCount += 1
    getEndpoint = endpoint

    completionHandler(getReturnResult())

    return getReturnValue
  }

  private func getReturnResult<T: Decodable>() -> Result<T> {
    if let result = getSuccessResult as? T {
      return .success(result)
    } else if let result = getErrorResult {
        return .failure(result)
    }

    return .failure(NetworkManagerMockError.unknown)
  }
}
