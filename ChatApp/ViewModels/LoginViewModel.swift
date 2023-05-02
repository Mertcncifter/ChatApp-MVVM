//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by mert can çifter on 26.04.2023.
//

import Foundation
import FirebaseAuth


protocol LoginViewModelProtocol {
    var delegate: LoginViewModelDelegate? { get set }
    func login(email: String, password: String)
}

enum LoginViewModelOutput{
    case setLoading(Bool)
    case error(error: String)
}

enum LoginViewRoute {
    case home
}

protocol LoginViewModelDelegate: AnyObject {
    func handleViewModelOutput(_ output: LoginViewModelOutput)
    func navigate(to route : LoginViewRoute)
}

final class LoginViewModel: LoginViewModelProtocol {
    
    weak var delegate: LoginViewModelDelegate?
    
    func login(email: String, password: String) {
        
        notify(.setLoading(true))
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            self?.notify(.setLoading(false))
            
            guard let result = authResult, error == nil else {
                self?.notify(.error(error: error?.localizedDescription ?? ""))
                return
            }
            
            DatabaseManager.shared.getDataFor(path: email.safeEmail) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    
                    UserDefaults.email = email
                    UserDefaults.name = "\(firstName) \(lastName)"
                    
                    self?.delegate?.navigate(to: .home)
                                
                case .failure(let failure):
                    print(failure)
                }
            }

        }
    }
    
    private func notify(_ output: LoginViewModelOutput){
        delegate?.handleViewModelOutput(output)
    }
    
}
