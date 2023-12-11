//
//  ViewController.swift
//  Messenger
//
//  Created by Arslan Raza on 22/11/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    var conversation = [Conversation]()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return tableView
    }()

    private var noConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeItem))
        self.view.addSubview(tableView)
        self.view.addSubview(noConversationLabel)
        tableViewSetup()
        fetchCoversations()
        startListeningForConversation()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        valideAuth()
    }
    
    private func startListeningForConversation() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] results in
            switch results {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversation = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to get conversation \(error.localizedDescription)")
            }
        }
    }
    
    @objc func didTapComposeItem() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id: "")
        vc.title = name
        vc.isNewConversation = true
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true )
    }
    
    private func valideAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let viewController = LoginViewController()
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func tableViewSetup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
    }
    
    private func fetchCoversations() {
        tableView.isHidden = false
    }

}


extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as? ConversationTableViewCell else {
            fatalError("cell not found")
        }
        let cellData = conversation[indexPath.row]
        cell.configure(with: cellData)
        
            let separatorView = UIView(frame: CGRect(x: tableView.separatorInset.left, y: 0, width: 20, height: 1))
            separatorView.backgroundColor = UIColor.gray
            separatorView.translatesAutoresizingMaskIntoConstraints  = false
            cell.contentView.addSubview(separatorView) //### <- add to subview before adding constraints
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo:cell.contentView.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo:cell.contentView.trailingAnchor),
                separatorView.heightAnchor.constraint(equalToConstant:1),
                separatorView.bottomAnchor.constraint(equalTo:cell.contentView.bottomAnchor)
                ])
        return cell
        
        
        
//        var cellContext = cell.defaultContentConfiguration()
//        cellContext.text = "Hello word"
//        cell.accessoryType = .disclosureIndicator
//        cell.contentConfiguration = cellContext
    } 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        let cellData = conversation[indexPath.row]
        let vc = ChatViewController(with: cellData.otherUserEmail, id: cellData.id)
        vc.isNewConversation = false
        vc.title = cellData.name
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
