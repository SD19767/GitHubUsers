//
//  DetailViewModel.swift
//  GitHubUsers
//
//  Created by Alvin on 2024/4/30.
//

import Foundation
import Combine

protocol DetailViewModelInput {
    func fetchUser() -> AnyPublisher<GitHubUser, Error>
    func updateUser() -> AnyPublisher<Void, Error>
}

class DetailViewModelOutput {
    @Published var user: GitHubUser
    var showError: AnyPublisher<String, Never> { showErrorSubject.eraseToAnyPublisher() }
    var showSuccess: AnyPublisher<Void, Never> { showSuccessSubject.eraseToAnyPublisher() }
    
    fileprivate let showErrorSubject = PassthroughSubject<String, Never>()
    fileprivate let showSuccessSubject = PassthroughSubject<Void, Never>()
    
    init(user: GitHubUser) {
        self.user = user
    }
}

class DetailViewModel: DetailViewModelInput {
    private let dataProvider = UserDataProvider()
    private let output: DetailViewModelOutput
    private var cancellables = Set<AnyCancellable>()
    
    init(user: GitHubUser) {
        self.output = DetailViewModelOutput(user: user)
    }
    
    func fetchUser() -> AnyPublisher<GitHubUser, Error> {
        return Future<GitHubUser, Error> { [weak self] promise in
            guard let self = self else { return }
            self.dataProvider.getUser(user: self.output.user) { result in
                switch result {
                case .success(let user):
                    self.output.user = user
                    promise(.success(user))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUser() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            let result = GitHubUsersRepository.shared.updateGitHubUser(by: self.output.user)
            switch result {
            case .success:
                self.output.showSuccessSubject.send(())
                promise(.success(()))
            case .failure(let error):
                self.output.showErrorSubject.send(error.localizedDescription)
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func bindOutput() -> DetailViewModelOutput {
        output.$user
            .sink { [weak self] user in
                // Perform any additional operations if needed
            }
            .store(in: &cancellables)
        
        return output
    }
}

