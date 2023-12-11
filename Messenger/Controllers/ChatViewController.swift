//
//  ChatViewController.swift
//  Messenger
//
//  Created by Arslan Raza on 29/11/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
   public var photoUrl: String
   public var senderId: String
   public var displayName: String
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController:  MessagesViewController {
    
    public static var dateformatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .current
        formatter.timeStyle = .long
        return formatter
    }
    
    public let otherUserEmail: String
    private let conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        return Sender(photoUrl: "", senderId: currentUserEmail, displayName: "Arslan Raza")
    }
    
    init(with email: String, id: String) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessages()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func listenForMessages() {
        
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty , let sender = self.selfSender , let messageId = createMessageId() else {
            return
        }
        
        //        send message
        if isNewConversation {
            // start new conversation
            let message = Message(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title ?? "Default name") { success in
                if success {
                    print("message sent")
                } else {
                    print("user not found")
                }
            }
        } else {
            // append in existing conversation
        }
    }
    
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        let saveCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = ChatViewController.dateformatter.string(from: Date())
        let newIdentifiler = "\(otherUserEmail)_\(saveCurrentEmail)_\(dateString)"
        print(newIdentifiler)
        return newIdentifiler
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        return Sender(photoUrl: "", senderId: "123", displayName: "Dummy sender")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}
