//
//  GitHubUsersViewModel.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/29.
//

import Foundation
import Combine

class GitHubUsersViewModel {
    private let repository = GitHubUsersRepository.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var tableControllers: [GitHubUsersTableViewController] = []
    @Published var totalPages: Int = 0
    @Published var userTotalCount: Int = 0
    private var isPaginationEnabled = true
    private let usersPerPage = 20
    
    init() {
        repository.$users
            .sink { [weak self] users in
                self?.updateTableControllers(with: users)
                self?.userTotalCount = users.count
            }
            .store(in: &cancellables)
    }
    
    func fetchGitHubUsers() {
        repository.fetchGitHubUsers()
    }
    
    func enablePagination() {
        isPaginationEnabled = true
        updateTableControllers(with: repository.users)
    }
    
    func disablePagination() {
        isPaginationEnabled = false
        updateTableControllers(with: repository.users)
    }
    
    private func updateTableControllers(with users: [GitHubUser]) {
        if isPaginationEnabled {
            tableControllers = createPaginatedTableControllers(with: users)
        } else {
            tableControllers = createNonPaginatedTableControllers(with: users)
        }
        totalPages = (users.count + usersPerPage - 1) / usersPerPage
    }
    
    private func createPaginatedTableControllers(with users: [GitHubUser]) -> [GitHubUsersTableViewController] {
        var tableControllers: [GitHubUsersTableViewController] = []
        var start = 0
        var indexOffset = 0
        while start < users.count {
            let tableViewController = GitHubUsersTableViewController()
            tableViewController.indexOffset = indexOffset
            let end = min(start + self.usersPerPage, users.count)
            let usersChunk = Array(users[start..<end])
            tableViewController.users = usersChunk
            tableControllers.append(tableViewController)
            start += self.usersPerPage
            indexOffset += self.usersPerPage
        }
        return tableControllers
    }
    
    private func createNonPaginatedTableControllers(with users: [GitHubUser]) -> [GitHubUsersTableViewController] {
        let tableViewController = GitHubUsersTableViewController()
        tableViewController.users = users
        return [tableViewController]
    }
}
