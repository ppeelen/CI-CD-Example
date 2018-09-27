//
//  ViewController.swift
//  ContinuousApp
//
//  Copyright © 2018 AppTrix AB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var fetchButton: UIButton!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
    didSet {
      loadingIndicator.isHidden = true
    }
  }
  @IBOutlet weak var errorLabel: UILabel! {
    didSet {
      errorLabel.isHidden = true
    }
  }

  private var users: [User] = []
  private var dataBoss: DataBoss

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    debugPrint("Hello!")
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.dataBoss = DataBoss()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  convenience init(dataBoss: DataBoss) {
    self.init(nibName: nil, bundle: nil)
    self.dataBoss = dataBoss
  }

  required init?(coder aDecoder: NSCoder) {
    dataBoss = DataBoss()
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension ViewController {

  @IBAction func fetchUsers(_ sender: Any) {
    fetchAllUsers()
  }
}

private extension ViewController {

  func fetchAllUsers() {
    loadingIndicator.startAnimating()
    loadingIndicator.isHidden = false

    fetchButton.isEnabled = false

    dataBoss.getAllUsers { [weak self](users, error) in
      guard let `self` = self else { return }

      if let error = error {
        if let error = error as? NetworkHandlerError {
          self.errorLabel.text = error.description
        } else {
          self.errorLabel.text = error.localizedDescription
        }
        self.errorLabel.isHidden = false
      } else if let users = users {
        self.users = users
        self.tableView.reloadData()
        self.errorLabel.text = ""
        self.errorLabel.isHidden = true
      }

      self.loadingIndicator.isHidden = true
      self.fetchButton.isEnabled = true
    }
  }
}

extension ViewController: UITableViewDelegate {

}

extension ViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()

    let user = users[indexPath.row]

    cell.textLabel?.text = "\(user.firstName) \(user.lastName)"

    return cell
  }
}
