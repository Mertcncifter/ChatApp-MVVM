//
//  NewChatViewModel.swift
//  ChatApp
//
//  Created by mert can çifter on 1.05.2023.
//

import Foundation

protocol NewChatViewModelProtocol {
    var delegate: NewChatViewModelDelegate? { get set }
    func searchUsers(query: String)
}

enum NewChatViewModelOutput{
    case setLoading(Bool)
    case error(error: String)
    case showResult([SearchResult])
}

enum NewChatViewRoute {
}

protocol NewChatViewModelDelegate: AnyObject {
    func handleViewModelOutput(_ output: NewChatViewModelOutput)
    func navigate(to route : NewChatViewRoute)
}

final class NewChatViewModel: NewChatViewModelProtocol {
    
    private var results = [SearchResult]()
    private var hasFetched = false
    private var users = [[String: String]]()

    private var databaseManager = DatabaseManager.shared
    weak var delegate: NewChatViewModelDelegate?
    private var email: String? = UserDefaults.email
    
    
    func searchUsers(query: String) {
        
        results.removeAll()
        notify(.showResult(results))
        
        notify(.setLoading(true))
        
        if hasFetched {
            self.filterUsers(with: query)
        } else {
            databaseManager.getAllUsers { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let failure):
                    print("\(failure)")
                }
            }
        }
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = email, hasFetched else {
            return
        }
        
        let safeEmail = currentUserEmail.safeEmail
        
        notify(.setLoading(false))

        let results: [SearchResult] = self.users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"],
                  let name = $0["name"] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })
        
        self.results = results
        notify(.showResult(results))

    }
    
    private func notify(_ output: NewChatViewModelOutput){
        delegate?.handleViewModelOutput(output)
    }
    
}

