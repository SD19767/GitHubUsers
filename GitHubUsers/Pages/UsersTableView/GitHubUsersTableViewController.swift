//
//  GitHubUsersTableViewController.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/30.
//

import UIKit

class GitHubUsersTableViewController: UITableViewController {
    var users: [GitHubUser] = []
    var indexOffset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(GitHubUserTableViewCell.self, forCellReuseIdentifier: "GitHubUserTableViewCell")
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GitHubUserTableViewCell", for: indexPath) as? GitHubUserTableViewCell else {
            fatalError("Failed to dequeue GitHubUserTableViewCell")
        }
        
        let user = users[indexPath.row]
        cell.configure(with: user, atIndex: indexPath.row + indexOffset)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = DetailViewModel(user: users[indexPath.row])
        let viewControllerToPresent = DetailViewController(viewModel: viewModel)
        if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
}
