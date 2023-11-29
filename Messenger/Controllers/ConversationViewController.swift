//
//  ViewController.swift
//  Messenger
//
//  Created by Arslan Raza on 22/11/2023.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Chats"
    }

    override func viewDidAppear(_ animated: Bool) {
        valideAuth()
    }
    
    private func valideAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let viewController = LoginViewController()
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

}

