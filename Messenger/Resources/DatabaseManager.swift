//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Arslan Raza on 23/11/2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// MARK: - Account Management
              
extension DatabaseManager {
    
    /// check the user exists
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// Insert new user to database
    public func insertUser(user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue(["first_name": user.firstName, "last_name": user.lastName, "emailAddress:": user.emailAddress]) { error, _ in
            guard error == nil else {
                print("falied to write in database")
                completion(false)
                return
            }
            
            
            self.database.child("users").observeSingleEvent(of: .value) { snapShot in
                if var userCollection = snapShot.value as? [[String: String]] {
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    
                    userCollection.append(newElement)
                    self.database.child("users").setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
                else {
                    let userCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    /// Fetch all users
    public func fetchUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        self.database.child("users").observeSingleEvent(of: .value, with: { snapShot  in
            guard let value = snapShot.value as? [[String: String]] else {
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseManagerError: Error {
        case failedToFetch
    }
}

// MARK: - Sending messages
extension DatabaseManager {
    
    /* "conversation" => [
                "conversationId": hfgawebfk,
                "other_user_email": text/photo/video,
                "latest_message": {
                    "date": Date(),
                    "latest_message": message,
                    "is_read": true/false,
                },
     ]*/
    
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let referance = database.child("\(safeEmail)")
        referance.observeSingleEvent(of: .value, with: { snapShot in
            guard var userNode = snapShot.value as? [String: Any] else {
                print("user not found")
                completion(false)
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateformatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let textMessage):
                message = textMessage
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = firstMessage.messageId
            let newConversation: [String : Any]  = [
                "id": "conversations_\(conversationId)",
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversation)
                userNode["conversations"] = conversations
                referance.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishConversation(conversationId: conversationId, firstMessage: firstMessage, name: name, completion: completion)
                }
            } else {
                userNode["conversations"] = [
                    newConversation
                ]
                
                referance.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishConversation(conversationId: conversationId, firstMessage: firstMessage, name: name, completion: completion)
                }
            }
        })
    }
    
    private func finishConversation(conversationId: String, firstMessage: Message, name: String, completion: @escaping (Bool) -> Void) {
        /* "hfgawebfk"{
               "messages": [
                    "id": String,
                    "type": text/photo/video,
                    "content": String,
                    "date": Date(),
                    "sender_email": String,
                    "is_Read": true/false,
         ]
         }*/
        
        var contentMessage = ""
        
        switch firstMessage.kind {
        case .text(let textMessage):
            contentMessage = textMessage
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateformatter.string(from: messageDate)
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            completion(false)
            return
        }
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": contentMessage,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name 
        ]
        
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        
        database.child("\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void)  {
        database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value as? [[String: Any]] else {
                completion(.failure(DatabaseManagerError.failedToFetch))
                return
            }

            let conversation: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool,
                      let date = latestMessage["date"] as? String else {

                      return nil
                }

                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            completion(.success(conversation))
        }
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}

/* users => [
 [
 "name": ,
 "email":
 ],
 [
 "name": ,
 "email":
 ]
 ]
 */

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_Profile_Picture_png"
    }
}
