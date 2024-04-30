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
    
    private init() {}
    
    func fetchGitHubUsers(completion: @escaping (Result<[GitHubUser], Error>) -> Void) {
        AF.request("https://api.github.com/users").responseDecodable(of: [GitHubUser].self) { response in
            switch response.result {
            case .success(let users):
                let limitedUsers = Array(users.prefix(100))
                completion(.success(limitedUsers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
