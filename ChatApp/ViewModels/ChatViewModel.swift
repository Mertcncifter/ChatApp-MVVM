//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by mert can çifter on 27.04.2023.
//

import Foundation
import UIKit

protocol ChatViewModelProtocol {
    var delegate: ChatViewModelDelegate? { get set }
    func load()
    func sendMessage(selfSender: Sender, text: String, title: String)
    func sendPhotoMessage(imageData: Data,selfSender: Sender,title: String)
    func sendVideoMessage(url: URL,selfSender: Sender,title: String)
}

enum ChatViewModelOutput{
    case setLoading(Bool)
    case error(error: String)
    case clearInputBar
    case showMessageList([Message])
}

enum ChatViewRoute {
}

protocol ChatViewModelDelegate: AnyObject {
    func handleViewModelOutput(_ output: ChatViewModelOutput)
    func navigate(to route : ChatViewRoute)
}

final class ChatViewModel: ChatViewModelProtocol {

    private let otherUserEmail: String
    private var conversationId: String?
    private var isNewConversation = false
    
    private var messages = [Message]()

    private var databaseManager = DatabaseManager.shared
    weak var delegate: ChatViewModelDelegate?
    
    init(with email: String, id: String?, newConversation: Bool? = false) {
        self.otherUserEmail = email
        self.conversationId = id
        if let newConversation = newConversation {
            self.isNewConversation = newConversation
        }
    }
    
    func load() {
        listenForMessages()
    }
    
    private func listenForMessages() {
        
        guard let conversationId = conversationId else {
            return
        }
        notify(.setLoading(true))

        databaseManager.getAllMessageForConversation(with: conversationId) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    self?.notify(.setLoading(false))
                    return
                }
                
                self?.messages = messages
                self?.notify(.setLoading(false))
                self?.notify(.showMessageList(messages))
            case .failure(_):
                break
            }
        }
    }
    
    func sendMessage(selfSender: Sender, text: String, title: String) {
        // Send Message
        
        delegate?.handleViewModelOutput(.clearInputBar)

        let messageId = createMessageId()
        let message = Message(sender: selfSender, messageId: messageId!, sentDate: Date(), kind: .text(text))

        if isNewConversation {
            // create convo in database
            
            databaseManager.createNewConversation(with: otherUserEmail, name: title, firstMessage: message) { [weak self] success,conversationId in
                if success {
                    self?.isNewConversation = false
                    self?.conversationId = conversationId
                    self?.listenForMessages()
                }
                else {
                    
                }
            }
        } else {
            // append to existing conversation data
            
            guard let conversationId = conversationId else {
                return
            }
            
            databaseManager.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: title, newMessage: message) { [weak self] success in
            }
        }
    }
    
    
    func sendPhotoMessage(imageData: Data,selfSender: Sender,title: String) {
        
        guard let messsageId = createMessageId() else {
            return
        }
                
        let fileName = "photo_message_" + messsageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
            switch result {
            case .success(let urlString):
                
                guard let conversationId = self?.conversationId,
                      let otherUserEmail = self?.otherUserEmail,
                      let  url = URL(string: urlString),
                      let placeHolder = UIImage(systemName: "plus") else {
                    return
                }
                
                let media = Media(url: url,image: nil,placeholderImage: placeHolder, size: .zero)
                
                let message = Message(sender: selfSender, messageId: messsageId, sentDate: Date(), kind: .photo(media))
                
                self?.databaseManager.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: title, newMessage: message) { [weak self] result in
                    
                }
                                
            case .failure(let error):
                print("Error \(error)")
            }
        }
    }
    
    func sendVideoMessage(url: URL,selfSender: Sender,title: String) {
        
        guard let messsageId = createMessageId() else {
            return
        }
                
        let fileName = "photo_message_" + messsageId.replacingOccurrences(of: " ", with: "-") + ".mov"
        
        StorageManager.shared.uploadMessageVideo(with: url, fileName: fileName) { [weak self] result in
            switch result {
            case .success(let urlString):
                
                guard let conversationId = self?.conversationId,
                      let otherUserEmail = self?.otherUserEmail,
                      let url = URL(string: urlString),
                      let placeHolder = UIImage(systemName: "plus") else {
                    return
                }
                
                let media = Media(url: url,image: nil,placeholderImage: placeHolder, size: .zero)
                
                let message = Message(sender: selfSender, messageId: messsageId, sentDate: Date(), kind: .video(media))
                
                self?.databaseManager.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: title, newMessage: message) { [weak self] result in
                    
                }
                                
            case .failure(let error):
                print("Error \(error)")
            }
        }
    }
    
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let dateString = Int(NSDate().timeIntervalSince1970)
        let newIdentifier = "\(otherUserEmail) \(currentUserEmail.safeEmail) \(dateString)"
        
        return newIdentifier
    }
    
    private func notify(_ output: ChatViewModelOutput){
        delegate?.handleViewModelOutput(output)
    }
    
}
