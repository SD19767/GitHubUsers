//
//  GitHubUsersRepostory.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/30.
//

import Foundation
import Alamofire

class GitHubUsersRepository {
    static let shared = GitHubUsersRepository()
    @Published var users: [GitHubUser] = []
    
    private init() {}
    
    func fetchGitHubUsers() {
        let dataProvider = UserDataProvider()
        dataProvider.getListUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print("Error fetching GitHub users: \(error)")
            }
        }
    }
    
    func updateGitHubUser(by user: GitHubUser) -> Result<Void, Error> {
        guard let index = users.firstIndex(where: { $0.login == user.login }) else {
            let error = NSError(domain: "GitHubUsersRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            return .failure(error)
        }
        
        if users[index].name != user.name {
            users[index].name = user.name
            return .success(())
        } else {
            let error = NSError(domain: "GitHubUsersRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "User name not updated"])
            return .failure(error)
        }
    }
}
