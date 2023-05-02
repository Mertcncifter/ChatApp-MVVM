//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by mert can çifter on 18.04.2023.
//

import FirebaseDatabase
import MessageKit
import UIKit

public enum DatabaseError: Error {
    case failedToFetch
}


final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

extension DatabaseManager {
    public func getDataFor(path: String, completion: @escaping(Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
}

// MARK: - Account Management

extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = email.safeEmail
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    public func insertUser(with user: ChatAppUser,completion: @escaping (Bool) -> Void) {
        database.child(user.emailAddress.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) { error, _ in
            
            guard error == nil else {
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                
                if var usersCollection = snapshot.value as? [[String: String]] {
                    
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.emailAddress.safeEmail
                    ]
                    
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                } else {
                  
                    let newCollection: [[String: String]] =
                    [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.emailAddress.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    }
                }
            })
            
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]],Error>) -> Void) {
        
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    
}


// MARK: - Sending messages / conversations

extension DatabaseManager {
    
    public func createNewConversation(with otherUserEmail: String, name: String ,firstMessage: Message, completion: @escaping (Bool,String?) -> Void) {
        guard let currentEmail = UserDefaults.email,
            let currentName = UserDefaults.name else {
            completion(false,nil)
            return
        }
        
        let safeEmail = currentEmail.safeEmail
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false,nil)
                return
            }
            
            let dateString = Int(NSDate().timeIntervalSince1970)
            
            let message = firstMessage.kind.getMessage
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }
                else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            }
            
            // Update Current User
        
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false,nil)
                        return
                    }
                    self?.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: { [weak self] success in
                        if success {
                            completion(true,conversationId)
                        } else {
                            completion(false,nil)
                        }
                    })
                }
            }
            else {
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false,nil)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: { [weak self] success in
                        if success {
                            completion(true,conversationId)
                        } else {
                            completion(false,nil)
                        }
                    })
                    
                }
            }
        }
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping(Bool) -> Void) {
        let dateString = Int(NSDate().timeIntervalSince1970)
        
        let message = firstMessage.kind.getMessage
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = myEmail.safeEmail
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
        
    }
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let timestamp = latestMessage["date"] as? Double,
                      let date = Date(timeIntervalSince1970: timestamp) as? Date,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))

            
        })
    }
    
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let timestamp = dictionary["date"] as? Double,
                      let date = Date(timeIntervalSince1970: timestamp) as? Date else {
                    return nil
                }
                
                var kind: MessageKind?
                
                if type == "photo" {
                    guard let imageUrl = URL(string: content),
                          let placeholder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: imageUrl,image: nil,placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }
                else if type == "video" {
                    guard let videoUrl = URL(string: content),
                          let placeholder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: videoUrl,image: nil,placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
               
                let sender = Sender(photoUrl: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date, kind:  finalKind)
            })
            
            completion(.success(messages))
            
        })
    }
    
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping(Bool) -> Void) {
        
        guard let myEmail = UserDefaults.email else {
            completion(false)
            return
        }
        
        let currentEmail = myEmail.safeEmail

        database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let dateString = Int(NSDate().timeIntervalSince1970)
            
            let message = newMessage.kind.getMessage
                        
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.updateConversation(conversation: conversation, email: currentEmail, otherUserEmail: otherUserEmail, date: dateString, message: message, name: name) { [weak self] success in
                    if success {
                        
                        guard let currentName = UserDefaults.name else {
                            return
                        }

                        strongSelf.updateConversation(conversation: conversation, email: otherUserEmail, otherUserEmail: currentEmail, date: dateString, message: message, name: currentName,completion: completion)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    private func updateConversation(conversation: String, email: String, otherUserEmail: String, date: Int, message: String, name: String, completion: @escaping(Bool) -> Void) {
        
        var databaseEntryConversations = [[String: Any]]()
        let updatedValue: [String: Any] = [
            "date": date,
            "message": message,
            "is_read": false
        ]
        
        self.database.child("\(email)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            if var userConversations = snapshot.value as? [[String: Any]] {
                
                var targetConversation: [String: Any]?
                var position = 0
                
                for conversationDictionary in userConversations {
                    if let currentId = conversationDictionary["id"] as? String,
                       currentId == conversation {
                        targetConversation = conversationDictionary
                        break
                    }
                    
                    position += 1
                }
                
                if var targetConversation = targetConversation {
                    targetConversation["latest_message"] = updatedValue
                    userConversations[position] = targetConversation
                    databaseEntryConversations = userConversations
                    
                } else {
                    let newConversationData: [String: Any] = [
                        "id": conversation,
                        "other_user_email": otherUserEmail.safeEmail,
                        "name": name,
                        "latest_message": updatedValue
                    ]
                    
                    userConversations.append(newConversationData)
                    databaseEntryConversations = userConversations
                }
                
            } else {
                let newConversationData: [String: Any] = [
                    "id": conversation,
                    "other_user_email": otherUserEmail.safeEmail,
                    "name": name,
                    "latest_message": updatedValue
                ]
                
                databaseEntryConversations = [newConversationData]
            }
            
            self?.database.child("\(email)/conversations").setValue(databaseEntryConversations) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                completion(true)
                
            }
        }
    }

    public func conversationExists(with targetRecipientEmail: String, completion: @escaping(Result<String, Error>) -> Void) {
        let safeRecipientEmail = targetRecipientEmail.safeEmail
        
        guard let senderEmail = UserDefaults.email else {
            return
        }
        
        let safeSenderEmail = senderEmail.safeEmail
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                
                return safeSenderEmail == targetSenderEmail
            }){
                
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                completion(.success(id))
                return
            }
            
            completion(.failure(DatabaseError.failedToFetch))
            return
        }
    }
}



