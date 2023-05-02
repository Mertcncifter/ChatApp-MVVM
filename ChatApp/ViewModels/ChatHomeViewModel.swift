//
//  ChatHomeViewModel.swift
//  ChatApp
//
//  Created by mert can çifter on 26.04.2023.
//

import Foundation

protocol ChatHomeViewModelProtocol {
    var delegate: ChatHomeViewModelDelegate? { get set }
    func openChat(model: Conversation)
    func newChat(result: SearchResult)
    func existChat(email: String, name: String)

}

enum ChatHomeViewModelOutput{
    case setLoading(Bool)
    case error(error: String)
    case showConversationList([Conversation])
}

enum ChatHomeViewRoute {
    case chat(email: String, id: String?, name: String, newConversation:Bool)
}

protocol ChatHomeViewModelDelegate: AnyObject {
    func handleViewModelOutput(_ output: ChatHomeViewModelOutput)
    func navigate(to route : ChatHomeViewRoute)
}

final class ChatHomeViewModel: ChatHomeViewModelProtocol {
    
    private var conversations = [Conversation]()
    private var databaseManager = DatabaseManager.shared
    weak var delegate: ChatHomeViewModelDelegate?
    private var email: String? = UserDefaults.email
    
    init() {
        load()
    }
    
    func load() {
        guard let email = email else {
            return
        }
    
        let safeEmail = email.safeEmail
        
        notify(.setLoading(true))
    
        databaseManager.getAllConversations(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.notify(.setLoading(false))
                    return
                }
                
                self?.conversations = conversations
                self?.notify(.setLoading(false))
                self?.notify(.showConversationList(conversations))
                
            case .failure(_):
                self?.notify(.setLoading(false))
                break
            }
        }
    }
    
    func openChat(model: Conversation) {
        delegate?.navigate(to: .chat(email: model.otherUserEmail, id: model.id, name: model.name, newConversation: false))
    }
    
    func newChat(result: SearchResult) {
                
        if let targetConversation = conversations.first(where: {
            $0.otherUserEmail == result.email.safeEmail
        }) {
            openChat(model: targetConversation)
        } else {
           createNewConversation(result: result)
        }
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = result.email
        
        existChat(email: email, name: name)
    }
    
    
    func existChat(email: String, name: String) {
        databaseManager.conversationExists(with: email) { [weak self] result in
            
            switch result {
            case .success(let conversationId):
                self?.delegate?.navigate(to: .chat(email: email, id: conversationId, name: name, newConversation: false))
            case .failure(_):
                self?.delegate?.navigate(to: .chat(email: email, id: nil, name: name, newConversation: true))
            }
        }
    }
    
    private func notify(_ output: ChatHomeViewModelOutput){
        delegate?.handleViewModelOutput(output)
    }
    
}


