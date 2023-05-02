//
//  RegisterViewModel.swift
//  ChatApp
//
//  Created by mert can çifter on 26.04.2023.
//

import Foundation
import FirebaseAuth

protocol RegisterViewModelProtocol {
    var delegate: RegisterViewModelDelegate? { get set }
    func register(email: String, password: String, firstName: String, lastName: String)
}

enum RegisterViewModelOutput{
    case setLoading(Bool)
    case error(error: String)
    case success
}


protocol RegisterViewModelDelegate: AnyObject {
    func handleViewModelOutput(_ output: RegisterViewModelOutput)
}

struct RegisterViewModel: RegisterViewModelProtocol {
    
    weak var delegate: RegisterViewModelDelegate?
    private var databaseManager = DatabaseManager.shared
    
    func register(email: String, password: String,firstName: String, lastName: String) {
        
        notify(.setLoading(true))
        
        DatabaseManager.shared.userExists(with: email) { exists in
            
            guard !exists else {
                notify(.error(error: "Error Email"))
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                guard let result = authResult, error == nil else {
                    notify(.setLoading(true))
                    notify(.error(error: error?.localizedDescription ?? ""))
                    return
                }
                
                UserDefaults.email = email
                UserDefaults.name = "\(firstName) \(lastName)"
                
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                
                databaseManager.insertUser(with: chatUser) { success in
                    notify(.success)
                }

            }
        }
    }
    
    private func notify(_ output: RegisterViewModelOutput){
        delegate?.handleViewModelOutput(output)
    }
    
}
