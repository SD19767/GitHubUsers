//
//  userDetailDataProvider.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/30.
//

import Foundation
import Alamofire

class UserDataProvider {
    func getListUsers(completion: @escaping (Result<[GitHubUser], Error>) -> Void) {
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
    
    func getUser(user: GitHubUser, completion: @escaping (Result<GitHubUser, Error>) -> Void) {
        AF.request("https://api.github.com/users/\(user.login)").responseDecodable(of: GitHubUser.self) { response in
            switch response.result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
