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
    @Published var users: [GitHubUser] = []
    @Published var totalPages: Int = 0
    private var isPaginationEnabled = true // 添加分頁模式的狀態
    private let usersPerPage = 20
    
    func fetchGitHubUsers() {
        if isPaginationEnabled {
            fetchGitHubUsersPaginated()
        } else {
            fetchGitHubUsersNonPaginated()
        }
    }
    
    func enablePagination() {
        isPaginationEnabled = true
        fetchGitHubUsers()
    }
    
    func disablePagination() {
        isPaginationEnabled = false
        fetchGitHubUsers()
    }
    
    private func fetchGitHubUsersPaginated() {
        repository.fetchGitHubUsers { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                let totalPages = (users.count + 19) / 20
                self.totalPages = totalPages
                self.users = users
                self.tableControllers = self.createPaginatedTableControllers(with: users)
            case .failure(let error):
                print("Error fetching GitHub users: \(error)")
            }
        }
    }
    
    private func fetchGitHubUsersNonPaginated() {
        repository.fetchGitHubUsers { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                self.users = users
                self.tableControllers = self.createNonPaginatedTableControllers(with: users)
            case .failure(let error):
                print("Error fetching GitHub users: \(error)")
            }
        }
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
